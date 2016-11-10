// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:auth/auth_credentials.dart';
import 'package:clients/gmail_client.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:models/email.dart';

/// A collection of allowed actions for the [EmailStore].
class EmailActions {
  // Private actions to be used in the fetchThreads() method.
  final Action<Null> _fetchThreads = new Action<Null>();
  final Action<List<Thread>> _fetchThreadsSuccess = new Action<List<Thread>>();
  final Action<Exception> _fetchThreadsFail = new Action<Exception>();

  /// Start fetching threads from the server.
  ///
  /// This method can be considered as an action creator which dispatches
  /// multiple actions for various stages of this asynchronous operation.
  ///
  /// 1. When the fetch operation is initiated, the _fetchThreads action is
  ///    emitted immediately.
  /// 2. When the asynchronous operation is finished, either
  ///    _fetchThreadsSuccess or _fetchThreadsFail action is emitted depending
  ///    on whether the operation was successful or not.
  void fetchThreads(AuthCredentials cred) {
    _fetchThreads();

    new GmailClient(accessToken: cred.accessToken)
        .getThreads()
        .then((GmailGetThreadsResponse r) => _fetchThreadsSuccess(r.threads))
        .catchError((Exception e) => _fetchThreadsFail(e));
  }

  /// Put the [Thread]s in the [EmailStore].
  ///
  /// This action does not interact with the server, and simply puts the given
  /// values to the store.
  final Action<List<Thread>> updateThreads = new Action<List<Thread>>();

  /// Toggles the message expansion status for the given id.
  final Action<String> toggleMessageExpansion = new Action<String>();
}

/// A flux [Store] that holds the user email data.
///
/// Currently, this [EmailStore] holds the email [Thread]s defined in the models
/// package, and some additional data necessary for UI widgets indicate current
/// states, such as whether the emails are being fetched, or whether an error
/// occurred.
class EmailStore extends Store {
  /// Creates a new instance of this [EmailStore].
  ///
  /// In this constructor, the [EmailStore] registers all the callbacks for the
  /// available actions.
  EmailStore(this.actions) {
    triggerOnAction(actions._fetchThreads, (_) {
      _fetching = true;
    });

    triggerOnAction(actions._fetchThreadsSuccess, (List<Thread> threads) {
      _updateThreads(threads);
    });

    triggerOnAction(actions._fetchThreadsFail, (Exception e) {
      _exception = e;
    });

    triggerOnAction(actions.updateThreads, (List<Thread> threads) {
      _updateThreads(threads);
    });

    triggerOnAction(actions.toggleMessageExpansion, (String messageId) {
      // Add to the map if it didn't exist before.
      if (!_expandedMessages.containsKey(messageId)) {
        _expandedMessages[messageId] = !getMessageById(messageId).isRead;
      }

      // Toggle it.
      _expandedMessages[messageId] = !_expandedMessages[messageId];
    });
  }

  /// The [EmailActions] instance associated with this [EmailStore].
  final EmailActions actions;

  /// The list of email [Thread]s.
  List<Thread> get threads => new List<Thread>.unmodifiable(_threads);
  final List<Thread> _threads = <Thread>[];

  // Derived maps from the thread list for easier lookup.
  Map<String, Thread> _threadMap = <String, Thread>{};
  Map<String, Message> _messageMap = <String, Message>{};

  /// Indicates whether the store is currently fetching emails.
  bool get fetching => _fetching;
  bool _fetching = false;

  /// Gets the last exception thrown while processing the email data.
  Exception get exception => _exception;
  Exception _exception;

  /// Stores whether a message is currently expanded or not.
  final Map<String, bool> _expandedMessages = <String, bool>{};

  /// Gets a [Thread] by its id.
  Thread getThreadById(String threadId) {
    return _threadMap[threadId];
  }

  /// Gets a [Message] by its id.
  Message getMessageById(String messageId) {
    return _messageMap[messageId];
  }

  /// Indicates whether a [Message] with the provided id needs to be expanded.
  bool isMessageExpanded(String messageId) {
    return _expandedMessages[messageId] ?? !_messageMap[messageId].isRead;
  }

  /// Updates the thread list and recreate the maps.
  void _updateThreads(List<Thread> threads) {
    _fetching = false;
    _exception = null;

    _threads.clear();
    _threads.addAll(threads);

    // Recreate the derived views for indexing.
    _threadMap = new Map<String, Thread>.fromIterable(
      threads,
      key: (Thread t) => t.id,
      value: (Thread t) => t,
    );

    _messageMap = new Map<String, Message>.fromIterable(
      threads.expand((Thread t) => t.messages),
      key: (Message m) => m.id,
      value: (Message m) => m,
    );
  }
}

/// Global [EmailActions] instance for the global [EmailStore].
final EmailActions kEmailActions = new EmailActions();

/// Global [StoreToken] for the [EmailStore].
final StoreToken kEmailStoreToken =
    new StoreToken(new EmailStore(kEmailActions));
