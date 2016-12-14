// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Represents a Gmail folder.
/// The main inbox (primary) and various labels can be thought of as folders.
class Label {
  /// ID for folder. Mainly for Gmail use.
  final String id;

  /// Name of folder. Ex. Primary, Social, Trash...
  final String name;

  /// Number of unread items in folder
  final int unread;

  /// Type of folder. Mainly for Gmail use.
  final String type;

  /// Constructor
  Label({
    this.id,
    this.name,
    this.unread: 0,
    this.type,
  });

  /// Create a [Label] from JSON.
  factory Label.fromJson(Map<String, dynamic> json) {
    String id = json['id'];
    String name = json['name'];
    String unread = json['unread'];
    String type = json['type'];

    return new Label(
      id: id,
      name: name,
      unread: int.parse(unread),
      type: type,
    );
  }

  /// Make it JSON.
  Map<String, String> toJson() {
    Map<String, String> json = new Map<String, String>();

    json['id'] = id;
    json['name'] = name;
    json['unread'] = unread.toString();
    json['type'] = type;

    return json;
  }
}
