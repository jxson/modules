// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:widget_specs/widget_specs.dart';

Future<Null> main() async {
  // TODO(youngseokyoon): Get this directory from the command line.
  String widgetsPackageDir = path.canonicalize(path.join(
      path.dirname(Platform.script.path),
      '..',
      '..',
      '..',
      'packages',
      'widgets'));

  List<WidgetSpecs> widgetSpecs = extractWidgetSpecs(widgetsPackageDir)..sort();
  print(widgetSpecs.join('\n-------------------------------\n'));
}
