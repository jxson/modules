// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_flux/flutter_flux.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';

/// Represents an active view session into an Email repository
abstract class EmailSessionStore implements Store {
  /// The current user profile
  User get user;

  /// Lables that are currently visible and should be displayed.
  List<Folder> get visibleFolders;

  /// The currently selected folder that has focus, if any.
  Folder get focusedFolder;

  /// Threads that are currently visible and should be displayed, if any
  List<Thread> get visibleThreads;

  /// The currently selected thread that has focus, if any.
  Thread get focusedThread;

  /// The currently outstanding errors with the store.
  /// (e.g. Network errors, API errors, etc. )
  List<Error> get currentErrors;

  /// Returns true if currently fetching emails from server
  bool get fetching;
  // TODO(alangardner): Current status? (e.g. loading, etc.)
}

/// The globally available email session store
/// HACK(alangardner): This needs to be instantiated before any access.
StoreToken kEmailSessionStoreToken;
