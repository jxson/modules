// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:yaml/yaml.dart' as yaml;
import 'package:path/path.dart' as path;

/// TODO(jasoncampbell): add documentation for this!
class Config {
  static Future<String> get(String key) async {

    String configfile = path.absolute('..', 'config.yaml');
    String normalized = path.normalize(configfile);

    print('normalized: $normalized');

    File file = new File(normalized);

    print('file: $file');

    if (!(await file.exists())) {
      throw new StateError('$file does not exist.');
    }

    dynamic data = yaml.loadYaml('');

    return 'foo';
  }
}
