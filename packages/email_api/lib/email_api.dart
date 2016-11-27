// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:config_flutter/config.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/oauth2/v2.dart' as oauth;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';
import 'package:util/extract_uri.dart';

const List<String> _kLabelSortOrder = const <String>[
  'INBOX',
  'STARRED',
  'DRAFT',
  'TRASH',
];

/// The interface to the Gmail REST API.
class EmailAPI {
  /// Google OAuth scopes.
  List<String> scopes;
  Client _baseClient;
  AutoRefreshingAuthClient _client;
  gmail.GmailApi _gmail;

  /// The [EmailAPI] constructor.
  EmailAPI({
    @required String id,
    @required String secret,
    @required String token,
    @required DateTime expiry,
    @required String refreshToken,
    @required this.scopes,
  }) {
    assert(id != null);
    assert(secret != null);
    assert(token != null);
    assert(expiry != null);
    assert(refreshToken != null);

    ClientId clientId = new ClientId(id, secret);
    AccessToken accessToken = new AccessToken('Bearer', token, expiry);
    AccessCredentials credentials =
        new AccessCredentials(accessToken, refreshToken, scopes);
    _baseClient = new Client();
    _client = autoRefreshingClient(clientId, credentials, _baseClient);
    _gmail = new gmail.GmailApi(_client);
  }

  /// Create an instance of [EmailAPI] by loading a config file.
  static Future<EmailAPI> fromConfig(String src) async {
    Config config = await Config.read(src);
    List<String> keys = <String>[
      'oauth_id',
      'oauth_secret',
      'oauth_token',
      'oauth_token_expiry',
      'oauth_refresh_token',
    ];
    config.validate(keys);

    return new EmailAPI(
        id: config.get('oauth_id'),
        secret: config.get('oauth_secret'),
        token: config.get('oauth_token'),
        expiry: DateTime.parse(config.get('oauth_token_expiry')),
        refreshToken: config.get('oauth_refresh_token'),
        scopes: config.scopes);
  }

  /// Get the logged in [User] object from [Oauth2Api].
  Future<User> me() async {
    oauth.Oauth2Api _oauth = new oauth.Oauth2Api(_client);
    oauth.Userinfoplus info = await _oauth.userinfo.get();

    return new User(
      id: info.id,
      email: info.email,
      name: info.name,
      picture: info.picture,
    );
  }

  /// Get a [Label] from the Gmail REST API.
  Future<Label> _label(String id) async {
    assert(id != null);

    gmail.Label label = await _gmail.users.labels.get('me', id);
    String type = label.type.toLowerCase();
    String name =
        type == 'system' ? _normalizeLabelName(label.name) : label.name;

    // Available properties on [gmail.Label]s are:
    //
    //       {
    //         "id": "INBOX",
    //         "name": "INBOX",
    //         "messageListVisibility": "hide",
    //         "labelListVisibility": "labelShow",
    //         "type": "system",
    //         "messagesTotal": 87,
    //         "messagesUnread": 82,
    //         "threadsTotal": 87,
    //         "threadsUnread": 82
    //       }
    //
    return new Label(
      id: label.id,
      name: name,
      unread: label.threadsUnread,
      type: label.type,
    );
  }

  /// Get a list of [Label]s from the Gmail REST API. By default only returns
  /// those in [_kLabelSortOrder].
  Future<List<Label>> labels({bool all: false}) async {
    gmail.ListLabelsResponse response = await _gmail.users.labels.list('me');
    Iterable<Future<Label>> requests = response.labels.map((gmail.Label label) {
      return new Future<Label>(() async {
        return await this._label(label.id);
      });
    });

    Stream<Label> stream = new Stream<Label>.fromFutures(requests);
    List<Label> labels = await stream.toList();

    List<Label> top = labels.where((Label label) {
      return _kLabelSortOrder.contains(label.id);
    }).toList();

    top.sort((Label a, Label b) {
      int indexA = _kLabelSortOrder.indexOf(a.id);
      int indexB = _kLabelSortOrder.indexOf(b.id);
      return indexA.compareTo(indexB);
    });

    if (all) {
      List<Label> bottom = labels.where((Label label) {
        return !_kLabelSortOrder.contains(label.id);
      }).toList();

      bottom.sort((Label a, Label b) {
        return a.name.compareTo(b.name);
      });

      top.addAll(bottom);
    }

    return top;
  }

  /// Get a [Thread] from the Gmail REST API.
  Future<Thread> _thread(String id) async {
    gmail.Thread t = await _gmail.users.threads.get('me', id);
    List<Message> messages =
        await Future.wait(t.messages.map((gmail.Message m) {
      return this._message(m);
    }));

    return new Thread(
      id: t.id,
      snippet: t.snippet,
      historyId: t.historyId,
      messages: messages,
    );
  }

  /// Get a list of [Thread]s from the Gmail REST API.
  Future<List<Thread>> threads({
    String labelId = 'INBOX',
    int max = 15,
  }) async {
    gmail.ListThreadsResponse response = await _gmail.users.threads.list(
      'me',
      labelIds: <String>[labelId],
      maxResults: max,
    );

    Iterable<Future<Thread>> requests =
        response.threads.map((gmail.Thread thread) {
      return new Future<Thread>(() async {
        return await this._thread(thread.id);
      });
    });

    Stream<Thread> stream = new Stream<Thread>.fromFutures(requests);
    List<Thread> threads = await stream.toList();

    return threads;
  }

  /// Get a [Message]s from the Gmail REST API.
  Future<Message> _message(gmail.Message message) async {
    String subject;
    Mailbox sender;
    List<Mailbox> to = <Mailbox>[];
    List<Mailbox> cc = <Mailbox>[];

    // TODO(jxson): SO-139 Add profile fetching for all users encountered.

    // Pull [Message] meta from [gmail.MessagePartHeader]s.
    message.payload.headers.forEach((gmail.MessagePartHeader header) {
      String name = header.name.toLowerCase();
      switch (name) {
        case 'from':
          sender = new Mailbox.fromString(header.value);
          break;
        case 'subject':
          subject = header.value;
          break;
        case 'to':
          to.addAll(_split(header));
          break;
        case 'cc':
          cc.addAll(_split(header));
          break;
      }
    });

    String body = _body(message);
    List<Uri> links = extractURI(body);

    return new Message(
      id: message.id,
      timestamp: _timestamp(message.internalDate),
      isRead: !message.labelIds.contains('UNREAD'),
      sender: sender,
      subject: subject,
      senderProfileUrl: null,
      recipientList: to,
      ccList: cc,
      text: body,
      links: links,
      attachments: _attachments(links),
    );
  }
}

String _normalizeLabelName(String string) {
  String value = string.replaceAll(new RegExp(r'CATEGORY_'), '');
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}

DateTime _timestamp(String stamp) {
  int ms = int.parse(stamp);
  return new DateTime.fromMillisecondsSinceEpoch(ms);
}

List<Mailbox> _split(gmail.MessagePartHeader header) {
  return header.value
      .split(', ')
      .map((String s) => new Mailbox.fromString(s))
      .toList();
}

String _body(gmail.Message message) {
  gmail.MessagePart part = message.payload.parts
      ?.reduce((gmail.MessagePart previous, gmail.MessagePart current) {
    if (current.mimeType == 'text/plain') {
      return current;
    }
  });

  if (part != null) {
    List<int> base64 = BASE64.decode(part.body.data);
    String utf8 = UTF8.decode(base64);
    return utf8;
  } else {
    return message.snippet;
  }
}

List<Attachment> _attachments(List<Uri> links) {
  // TODO(jxson): SO-138 separate detection and extraction.
  return links.where((Uri link) {
    return link.host == 'www.youtube.com' || link.host == 'tools.usps.com';
  }).map((Uri link) {
    if (link.host == 'www.youtube.com' &&
        link.path == '/watch' &&
        link.queryParameters['v'] != null) {
      return new Attachment(
        type: AttachmentType.youtubeVideo,
        value: link.queryParameters['v'],
      );
    } else if (link.host == 'tools.usps.com' &&
        link.path == '/go/TrackConfirmAction' &&
        link.queryParameters['qtc_tLabels1'] != null) {
      return new Attachment(
        type: AttachmentType.uspsShipping,
        value: link.queryParameters['qtc_tLabels1'],
      );
    }
  }).toList();
}
