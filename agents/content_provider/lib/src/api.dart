// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:email_api/email_api.dart';

/// Helper to access and contain an EmailAPI singleton.
class API {
  static EmailAPI _api;

  /// Async getter/loader.
  static Future<EmailAPI> get() async {
    if (_api != null) {
      return _api;
    }

    _api = await EmailAPI.fromConfig('/system/data/modules/config.json');
    return _api;
  }
}
