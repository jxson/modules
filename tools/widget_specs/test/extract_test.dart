// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:widget_specs/widget_specs.dart';

import 'util.dart';

void main() {
  String mockPackagePath = path.join(getTestDataPath(), 'mock_package');
  List<WidgetSpecs> widgetSpecs = extractWidgetSpecs(mockPackagePath);
  Map<String, WidgetSpecs> widgetMap =
      new Map<String, WidgetSpecs>.fromIterable(
    widgetSpecs,
    key: (WidgetSpecs ws) => ws.name,
    value: (WidgetSpecs ws) => ws,
  );

  test('extractWidgetSpecs() should extract only public flutter widgets.', () {
    expect(
        widgetMap.keys,
        unorderedEquals(<String>[
          'Widget01',
          'Widget03',
          'NoCommentWidget',
        ]));
  });

  test('extractWidgetSpecs() should correctly extract dartdoc comments.', () {
    expect(
      widgetMap['Widget01'].doc,
      equals('This is a public [StatefulWidget].'),
    );
    expect(
      widgetMap['Widget03'].doc,
      equals('This is a public [StatelessWidget].'),
    );
    expect(widgetMap['NoCommentWidget'].doc, isNull);
  });

  test('extractWidgetSpecs() should correctly extract the package name.', () {
    widgetMap.keys.forEach((String key) {
      expect(widgetMap[key].packageName, equals('mock_package'));
    });
  });

  test('extractWidgetSpecs() should correctly extract the path.', () {
    widgetMap.keys.forEach((String key) {
      expect(widgetMap[key].path, equals('src/sample_widgets.dart'));
    });
  });
}
