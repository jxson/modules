// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:email_service/api.dart' as api;

/// Represents a Gmail folder.
/// The main inbox (primary) and various labels can be thought of as folders.
class Folder {
  /// ID for folder. Mainly for Gmail use.
  final String id;

  /// Name of folder. Ex. Primary, Social, Trash...
  final String name;

  /// Number of unread items in folder
  final int unread;

  /// Type of folder. Mainly for Gmail use.
  final String type;

  /// Constructor
  Folder({
    this.id,
    this.name,
    this.unread: 0,
    this.type,
  });

  /// Create a [Folder] from a Gmail API Label model
  factory Folder.fromGmailApi(api.Label label) {
    return new Folder(
      id: label.id,
      name: label.type == 'SYSTEM'
          ? '${label.name[0].toUpperCase()}${label.name.substring(1).toLowerCase()}'
          : label.name,
      unread: label.threadsUnread,
      type: label.type,
    );
  }
}
