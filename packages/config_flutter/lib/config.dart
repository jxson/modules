// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:config/config.dart';
import 'package:flutter/services.dart' show rootBundle;

class Config extends BaseConfig {
  /// Convienence method for creating a config object by loading a
  /// configuration file at [src].
  static Future<Config> read(String src) async {
    Config config = new Config();
    await config.load(src);
    return config;
  }

  @override
  Future<Null> load(String src) async {
    String data = await rootBundle.loadString(src);
    dynamic json = JSON.decode(data);
    json.forEach((String key, String value) => this.put(key, value));
  }
}
