// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'label.dart';

/// Data model that represents a grouping of email labels
/// This is typically manifested in the Gmail style main menu
class LabelGroup {
  /// List of [Label]s that belong in this [LabelGroup]
  List<Label> labels;

  /// Name of this label group. A [LabelGroup] does not require a name.
  String name;

  /// Constructor
  LabelGroup({
    this.labels: const <Label>[],
    this.name,
  });
}
