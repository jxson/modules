// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

/// Abstract class providing a basic configuration to be implemented in both
/// Flutter and CLI/tooling environements.
abstract class BaseConfig {
  /// OAuth Scopes.
  /// SEE: https://developers.google.com/identity/protocols/googlescopes
  List<String> scopes = <String>[
    'https://www.googleapis.com/auth/gmail.modify',
    'https://www.googleapis.com/auth/youtube.readonly',
  ];

  final Map<String, String> _data = <String, String>{};

  /// Configuration loading needs to be defined separately for each unique
  /// environement, Flutter versus CLI.
  Future<Null> load(String src);

  /// Check is the configuration has a value for [key].
  bool has(String key) {
    return _data.containsKey(key);
  }

  /// Retrieve a config value.
  String get(String key) {
    return _data[key];
  }

  /// Add or update a config value.
  void put(String key, String value) {
    _data[key] = value;
  }

  /// Create a [Map] for use in JSON encoding.
  Map<String, String> toJSON() {
    return _data;
  }
}
