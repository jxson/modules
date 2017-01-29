// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_flux/flutter_flux.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';

export 'package:flutter_flux/flutter_flux.dart';

/// Represents an active view session into an Email repository
abstract class EmailSessionStore implements Store {
  /// The current user profile
  User get user;

  /// Lables that are currently visible and should be displayed.
  List<Label> get visibleLabels;

  /// The currently selected label that has focus, if any.
  Label get focusedLabel;

  /// Threads that are currently visible and should be displayed, if any
  List<Thread> get visibleThreads;

  /// The currently selected thread that has focus, if any.
  Thread get focusedThread;

  /// The currently outstanding errors with the store.
  /// (e.g. Network errors, API errors, etc. )
  List<Error> get currentErrors;

  /// Returns true if currently fetching labels from server
  bool get fetchingLabels;
  // TODO(alangardner): Current status? (e.g. loading, etc.)

  /// Returns true if currently fetching threads from server
  bool get fetchingThreads;

  /// Returns true if message should be expanded in the threadListView
  /// TODO(dayang): Make idempotent in the future
  bool messageIsExpanded(Message message);
}

/// The globally available email session store
/// HACK(alangardner): This needs to be instantiated before any access.
StoreToken kEmailSessionStoreToken;

/// Make this label the focused label
final Action<Label> emailSessionFocusLabel = new Action<Label>();

/// Make this thread the focused thread
final Action<Thread> emailSessionFocusThread = new Action<Thread>();

/// Toggle the expansion of a message in a thread view
final Action<Message> emailSessionToggleMessageExpand = new Action<Message>();

/// Marks given message as read
final Action<Message> emailSessionMarkMessageAsRead = new Action<Message>();

/// Sends given thread to trash
final Action<Thread> emailSessionMoveThreadToTrash = new Action<Thread>();
