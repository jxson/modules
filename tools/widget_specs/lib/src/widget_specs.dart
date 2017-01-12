// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A class describing the specifications of a custom flutter widget.
class WidgetSpecs implements Comparable<WidgetSpecs> {
  /// Creates a new instance of [WidgetSpecs] class with the given parameters.
  WidgetSpecs({
    this.name,
    this.doc,
  });

  /// Name of the widget.
  final String name;

  /// Contents of the document comments associated with the widget.
  final String doc;

  @override
  int compareTo(WidgetSpecs other) {
    return this.name.compareTo(other.name);
  }

  @override
  String toString() => '''WidgetSpecs: $name

$doc''';
}
