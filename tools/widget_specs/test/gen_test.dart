// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:widget_specs/widget_specs.dart';

import 'util.dart';

void main() {
  test('gen_widget_specs tool should correctly generate the expected files.',
      () async {
    String mockPackagePath =
        path.join(getTestDataPath(basename: 'extract_test'), 'mock_package');

    String packagePath = path.normalize(path.join(
      getTestScriptPath(),
      '..',
      '..',
    ));

    // Temp output dir.
    Directory tempDir = await Directory.systemTemp.createTemp();
    String outputPath = tempDir.path;

    // Run the gen script.
    print(outputPath);
    ProcessResult result = await Process.run(
      'pub',
      <String>['run', 'gen_widget_specs.dart', mockPackagePath, outputPath],
      workingDirectory: packagePath,
    );

    expect(result.exitCode, equals(0));

    List<String> createdFiles = new Directory(outputPath)
        .listSync()
        .map((FileSystemEntity entity) => path.basename(entity.path))
        .toList();
    expect(
        createdFiles,
        unorderedEquals(<String>[
          'index.dart',
          'widget01.dart',
          'widget03.dart',
          'no_comment_widget.dart',
        ]));
  });
}
