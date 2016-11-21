// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:email_session/email_session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:models/email.dart';
import 'package:widgets/email.dart';

/// An email menu/folder screen that shows a list of folders, built with the
/// flux pattern.
class EmailMenuScreen extends StoreWatcher {
  /// Creates a new [EmailMenuScreen] instance
  EmailMenuScreen({Key key}) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(kEmailSessionStoreToken);
  }

  @override
  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    final EmailSessionStore emailSession = stores[kEmailSessionStoreToken];

    if (emailSession.fetchingFolders) {
      return new Center(child: new CircularProgressIndicator());
    }

    if (emailSession.currentErrors.isNotEmpty) {
      // TODO(alangardner): Grab more than just the first error.
      Error error = emailSession.currentErrors[0];
      return new Text('Error occurred while retrieving email folders: '
          '$error');
    }

    FolderGroup primaryFolders = new FolderGroup(
      folders: emailSession.visibleFolders,
    );

    return new InboxMenu(
      folderGroups: <FolderGroup>[primaryFolders],
      onSelectFolder: emailSessionFocusFolder.call,
      selectedFolder: emailSession.focusedFolder,
      user: emailSession.user,
    );
  }
}
