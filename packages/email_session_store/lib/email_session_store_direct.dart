// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:email_api/email_api.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';

import 'email_session_store.dart';

/// An implemenation of EmailSession that fetches data directly over HTTP
class EmailSessionStoreDirect extends Store implements EmailSessionStore {
  User _user;
  List<Label> _visibleLabels;
  String _focusedLabelId;
  List<Thread> _visibleThreads;
  String _focusedThreadId;
  List<Error> _currentErrors;
  List<String> _expandedMessageIds;
  bool _fetchingLabels;
  bool _fetchingThreads;
  EmailAPI _api;

  /// Default constructor, which initializes to empty content.
  EmailSessionStoreDirect() {
    _visibleLabels = new List<Label>.unmodifiable(<Label>[]);
    _focusedLabelId = null;
    _visibleThreads = new List<Thread>.unmodifiable(<Thread>[]);
    _focusedThreadId = null;
    _currentErrors = new List<Error>.unmodifiable(<Error>[]);
    _fetchingLabels = true;
    _fetchingThreads = true;
    _expandedMessageIds = <String>[];
    triggerOnAction(emailSessionFocusLabel, (Label folder) {
      _focusedLabelId = folder.id;
      _fetchThreadsForFocusedLabel();
    });
    triggerOnAction(emailSessionFocusThread, (Thread thread) {
      _focusedThreadId = thread.id;
    });
    triggerOnAction(emailSessionToggleMessageExpand, _toggleMessageExpand);
  }

  /// Async helper to get an instance of EmailAPI. If one doesn't exist it
  /// will be created and returned. Subsequent calls will return the
  /// previously instantiated EmailAPI instance.
  Future<EmailAPI> api() async {
    if (_api != null) {
      return _api;
    }

    _api = await EmailAPI.fromConfig('assets/config.json');
    return _api;
  }

  @override
  User get user {
    return _user;
  }

  @override
  List<Label> get visibleLabels {
    return _visibleLabels;
  }

  @override
  Label get focusedLabel {
    return _visibleLabels.firstWhere(
        (Label folder) => folder.id == _focusedLabelId,
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
  bool messageIsExpanded(Message message) {
    return _expandedMessageIds.contains(message.id);
  }

  @override
  bool get fetchingLabels {
    return _fetchingLabels;
  }

  @override
  bool get fetchingThreads {
    return _fetchingThreads;
  }

  void _toggleMessageExpand(Message message) {
    if (_expandedMessageIds.contains(message.id)) {
      _expandedMessageIds.remove(message.id);
    } else {
      _expandedMessageIds.add(message.id);
    }
  }

  /// Retrieve threads currently focused label/folder and replace store with
  /// those threads
  Future<Null> _fetchThreadsForFocusedLabel() async {
    _focusedThreadId = null;
    _fetchingThreads = true;
    trigger();

    EmailAPI email = await api();
    _visibleThreads = await email.threads(
      labels: <String>[_focusedLabelId],
      max: 15,
    );

    // update fetching status
    _fetchingThreads = false;
    trigger();
  }

  /// Retrieves the "main" folders: Inbox, Starred, Draft, Trash
  Future<Null> _fetchLabels() async {
    _fetchingLabels = true;
    trigger();

    EmailAPI email = await api();
    _visibleLabels = await email.labels();
    _user = await email.me();

    _fetchingLabels = false;
    trigger();
  }

  /// Asynchronously fetch data for the email session from gmail servers
  Future<Null> fetchInitialContentWithGmailApi() async {
    // Set 'INBOX' as the default focused label
    _focusedLabelId = 'INBOX';

    // Fetch Labels
    await _fetchLabels();

    // Fetch Threads
    await _fetchThreadsForFocusedLabel();

    return null;
  }
}
