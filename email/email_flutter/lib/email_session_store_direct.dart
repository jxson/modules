// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show JSON;

import 'package:email_api/api.dart' as api;
import 'package:email_session/email_session_store.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_flux/flutter_flux.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';

/// An implemenation of EmailSession that fetches data directly over HTTP
class EmailSessionStoreDirect extends Store implements EmailSessionStore {
  api.GmailApi _gmail;
  User _user;
  List<Folder> _visibleLabels;
  String _focusedLabelId;
  List<Thread> _visibleThreads;
  String _focusedThreadId;
  List<Error> _currentErrors;
  bool _fetching;

  /// Default constructor, which initializes to empty content.
  EmailSessionStoreDirect() {
    _visibleLabels = new List<Folder>.unmodifiable(<Folder>[]);
    _focusedLabelId = null;
    _visibleThreads = new List<Thread>.unmodifiable(<Thread>[]);
    _focusedThreadId = null;
    _currentErrors = new List<Error>.unmodifiable(<Error>[]);
    _fetching = true;
    triggerOnAction(emailSessionFocusFolder, (Folder folder) {
      _focusedLabelId = folder.id;
      _fetchThreadsForFocusedLabel();
    });
    triggerOnAction(emailSessionFocusThread, (Thread thread) {
      _focusedThreadId = thread.id;
    });
  }

  @override
  User get user {
    return _user;
  }

  @override
  List<Folder> get visibleFolders {
    return _visibleLabels;
  }

  @override
  Folder get focusedFolder {
    return _visibleLabels.firstWhere(
        (Folder folder) => folder.id == _focusedLabelId,
        orElse: () => null);
  }

  @override
  List<Thread> get visibleThreads {
    return _visibleThreads;
  }

  @override
  Thread get focusedThread {
    return _visibleThreads.firstWhere(
        (Thread thread) => thread.id == _focusedThreadId,
        orElse: () => null);
  }

  @override
  List<Error> get currentErrors {
    return _currentErrors;
  }

  @override
  bool get fetching {
    return _fetching;
  }

  /// Retrieve threads currently focused label/folder and replace store with
  /// those threads
  Future<Null> _fetchThreadsForFocusedLabel() async {
    if (_gmail == null) {
      return null;
    }

    api.ListThreadsResponse response = await _gmail.users.threads
        .list('me', labelIds: <String>[_focusedLabelId], maxResults: 15);
    List<api.Thread> fullThreads = await Future.wait(response.threads
        .map((api.Thread t) => _gmail.users.threads.get('me', t.id)));
    _visibleThreads = new List<Thread>.unmodifiable(
        fullThreads.map((api.Thread t) => new Thread.fromGmailApi(t)));
    trigger();
  }

  /// Asynchronously fetch data for the email session from gmail servers
  Future<Null> fetchInitialContentWithGmailApi() async {
    _gmail =
        await rootBundle.loadString('assets/config.json').then((String data) {
      dynamic map = JSON.decode(data);

      api.Client client = api.client(
          id: map['oauth_id'],
          secret: map['oauth_secret'],
          token: map['oauth_token'],
          expiry: DateTime.parse(map['oauth_token_expiry']),
          refreshToken: map['oauth_refresh_token']);

      return new api.GmailApi(client);
    }).catchError((Error error) {
      print('Error loading config file.');
    });
    if (_gmail == null) {
      return null;
    }

    // Set 'INBOX' as the default focused label
    _focusedLabelId = 'INBOX';

    // Fetch Threads
    await _fetchThreadsForFocusedLabel();

    // Get Folder Data
    List<String> foldersWeCareAbout = <String>[
      'INBOX',
      'STARRED',
      'DRAFT',
      'TRASH',
    ];
    List<api.Label> fullLabels = await Future.wait(foldersWeCareAbout
        .map((String folderName) => _gmail.users.labels.get('me', folderName)));
    _visibleLabels = new List<Folder>.unmodifiable(
        fullLabels.map((api.Label label) => new Folder.fromGmailApi(label)));

    // Get User Data
    // TODO(jasoncampbell): Expand scope of OAuth token so we can retrieve the
    // "plus profile" that has more data
    // https://fuchsia.atlassian.net/browse/SO-134
    api.Profile userProfile = await _gmail.users.getProfile('me');
    _user = new User(
      name: userProfile.emailAddress,
      email: userProfile.emailAddress,
    );

    _fetching = false;
    trigger();
    return null;
  }
}
