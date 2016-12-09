// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_flux/flutter_flux.dart';
import 'package:models/email.dart';
import 'package:models/fixtures.dart';
import 'package:models/user.dart';

import 'email_session_store.dart';

export 'email_session_store.dart';

/// A mock implemenation of EmailSession
class EmailSessionStoreMock extends Store implements EmailSessionStore {

  User _user;
  List<Label> _visibleLabels;
  String _focusedLabelId;
  List<Thread> _visibleThreads;
  String _focusedThreadId;
  List<Error> _currentErrors;
  List<String> _expandedMessageIds;
  bool _fetchingLabels;
  bool _fetchingThreads;

  /// Default constructor, which initializes to mock content.
  EmailSessionStoreMock() {
    ModelFixtures fixtures = new ModelFixtures();

    _user = fixtures.user();
    _visibleLabels = fixtures.labels();
    _focusedLabelId = _visibleLabels.isEmpty ? null : _visibleLabels[0].id;
    _visibleThreads = fixtures.threads();
    _focusedThreadId = _visibleThreads.isEmpty ? null : _visibleThreads[0].id;
    _currentErrors = const <Error>[];
    _fetchingLabels = false;
    _fetchingThreads = false;
    _expandedMessageIds = <String>[];

    triggerOnAction(emailSessionFocusLabel, (Label folder) {
      _focusedLabelId = folder.id;
    });
    triggerOnAction(emailSessionFocusThread, (Thread thread) {
      _focusedThreadId = thread.id;
    });
    triggerOnAction(emailSessionToggleMessageExpand, _toggleMessageExpand);
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
}
