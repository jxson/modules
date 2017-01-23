// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';

/// A class describing the specifications of a custom flutter widget.
class WidgetSpecs implements Comparable<WidgetSpecs> {
  /// Creates a new instance of [WidgetSpecs] class with the given parameters.
  WidgetSpecs({
    this.packageName,
    this.name,
    this.path,
    this.doc,
    this.classElement,
  });

  /// Name of the package in which this widget is defined.
  final String packageName;

  /// Name of the widget.
  final String name;

  /// Path of the dart file (under `lib`) where this widget is defined.
  final String path;

  /// Contents of the document comments associated with the widget.
  final String doc;

  /// The [ClassElement] corresponding to this widget.
  final ClassElement classElement;

  @override
  int compareTo(WidgetSpecs other) {
    return this.name.compareTo(other.name);
  }

  @override
  String toString() => '''WidgetSpecs: $name

$doc''';
}
