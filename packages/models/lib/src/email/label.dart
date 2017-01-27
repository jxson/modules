// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:widgets_meta/widgets_meta.dart';

import '../fixtures/fixtures.dart';

/// Represents a Gmail folder.
/// The main inbox (primary) and various labels can be thought of as folders.
@Generator(ModelFixtures, 'label')
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
    int unread = json['unread'];
    String type = json['type'];

    if (unread is! int) {
      unread = 0;
    }

    return new Label(
      id: id,
      name: name,
      unread: unread,
      type: type,
    );
  }

  /// Helper function for JSON.encode().
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};

    json['id'] = id;
    json['name'] = name;
    json['unread'] = unread;
    json['type'] = type;

    return json;
  }
}
