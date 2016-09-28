// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Represents a Gmail folder.
/// The main inbox (primary) and various labels can be thought of as folders.
class Folder {
  /// ID for folder. Mainly for Gmail use.
  String id;

  /// Name of folder. Ex. Primary, Social, Trash...
  String name;

  /// Number of unread items in folder
  int unread;

  /// Type of folder. Mainly for Gmail use.
  String type;

  /// Constructor
  Folder({
    this.id,
    this.name,
    this.unread: 0,
    this.type,
  });
}
