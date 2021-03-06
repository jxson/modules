// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show JSON;

import 'package:flutter/http.dart' as http;
import 'package:models/email.dart';

import 'email_client.dart';

/// Function that returns the desired [Client] to be used.
typedef http.Client HttpClientProvider();

http.Client _defaultHttpClientProvider() {
  return new http.Client();
}

/// An [EmailClient] implementation for Gmail.
class GmailClient extends EmailClient {
  final String _accessToken;
  final HttpClientProvider _httpClientProvider;

  /// Creates a new instance of [GmailClient] object with the given token.
  /// The token should be obtained using OAuth 2.0 before creating this object.
  GmailClient({
    String accessToken: '',
    HttpClientProvider httpClientProvider: _defaultHttpClientProvider,
  })
      : _accessToken = accessToken,
        _httpClientProvider = httpClientProvider;

  @override
  Future<GmailGetThreadsResponse> getThreads({dynamic args}) async {
    Map<String, String> headers = <String, String>{
      'Authorization': 'Bearer $_accessToken',
    };

    // For now, limit to 20 threads by default.
    Map<String, dynamic> params = <String, dynamic>{
      'maxResults': '20',
    };

    if (args != null && args is Map<String, dynamic>) {
      args.keys.forEach((String key) {
        params[key] = args[key];
      });
    }

    // First, retrieve the thread ids.
    Uri uri = new Uri(
      scheme: 'https',
      host: 'www.googleapis.com',
      path: '/gmail/v1/users/me/threads',
      queryParameters: params,
    );

    http.Response response =
        await _httpClientProvider().get(uri, headers: headers);
    dynamic jsonResponse = JSON.decode(response.body);

    if (jsonResponse['threads'] == null) {
      return new GmailGetThreadsResponse(<Thread>[]);
    }

    List<dynamic> jsonThreads = jsonResponse['threads'];
    List<Thread> threads = <Thread>[];
    for (dynamic jsonThread in jsonThreads) {
      threads.add(await getThread(jsonThread['id']));
    }
    return new GmailGetThreadsResponse(threads);
  }

  @override
  Future<Thread> getThread(String threadId, {dynamic args}) async {
    Map<String, String> headers = <String, String>{
      'Authorization': 'Bearer $_accessToken',
    };

    Uri uri = new Uri(
      scheme: 'https',
      host: 'www.googleapis.com',
      path: '/gmail/v1/users/me/threads/$threadId',
      queryParameters: <String, dynamic>{
        'labelIds': 'INBOX',
      },
    );

    http.Response response =
        await _httpClientProvider().get(uri, headers: headers);
    dynamic jsonResponse = JSON.decode(response.body);

    return _createThreadFromJSON(jsonResponse);
  }

  static Message _createMessageFromJSON(dynamic json) {
    String id = json['id'];

    String subject = '';
    Mailbox sender;
    List<Mailbox> recipientList = <Mailbox>[];
    List<Mailbox> ccList = <Mailbox>[];

    dynamic headers = json['payload']['headers'];
    for (dynamic header in headers) {
      switch (header['name'].toString().toLowerCase()) {
        case 'from':
          sender = new Mailbox.fromString(header['value'].toString());
          break;

        case 'to':
          header['value'].toString().split(', ').forEach((String rawAddress) {
            recipientList.add(new Mailbox.fromString(rawAddress));
          });
          break;

        case 'cc':
          header['value'].toString().split(', ').forEach((String rawAddress) {
            ccList.add(new Mailbox.fromString(rawAddress));
          });
          break;

        case 'subject':
          subject = header['value'].toString();
          break;
      }
    }

    String text = json['snippet'] ?? '';

    bool isRead = !json['labelIds'].contains('UNREAD');

    DateTime timestamp = new DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['internalDate']));

    return new Message(
      id: id,
      sender: sender,
      senderProfileUrl: null,
      recipientList: recipientList,
      ccList: ccList,
      subject: subject,
      text: text,
      timestamp: timestamp,
      isRead: isRead,
    );
  }

  static Thread _createThreadFromJSON(dynamic json) {
    String id = json['id'];
    String snippet = json['snippet'] ?? '';
    String historyId = json['historyId'].toString();

    List<dynamic> jsonMessages = json['messages'];
    List<Message> messages = <Message>[];
    if (jsonMessages != null) {
      jsonMessages.forEach((dynamic jsonMessage) {
        messages.add(_createMessageFromJSON(jsonMessage));
      });
    }

    return new Thread(
      id: id,
      snippet: snippet,
      historyId: historyId,
      messages: messages,
    );
  }
}

// TODO(youngseokyoon): add some Gmail-specific data such as next page token.
/// A [GetThreadsResponse] implementation specific to Gmail.
class GmailGetThreadsResponse extends GetThreadsResponse {
  /// Creates an instance of [GmailGetThreadsResponse] object.
  GmailGetThreadsResponse(List<Thread> threads) : super(threads);
}
