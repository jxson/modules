// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'folder.dart';

/// Data model that represents a grouping of email folders
/// This is typically manifested in the Gmail style main menu
class FolderGroup {
  /// List of [Folder]s that belong in this [FolderGroup]
  List<Folder> folders;

  /// Name of this folder group. A [FolderGroup] does not require a name.
  String name;

  /// Constructor
  FolderGroup({
    this.folders: const <Folder>[],
    this.name,
  });
}
