// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:email_api/email_api.dart';

void _log(String msg) {
  print('[email_service:api] $msg');
}

/// Helper to access and contain an EmailAPI singleton.
class API {
  static EmailAPI _api;

  /// Async getter/loader.
  static Future<EmailAPI> get() async {
    if (_api != null) {
      return _api;
    }

    try {
      _api = await EmailAPI.fromConfig('/system/data/modules/config.json');
    } catch (err) {
      _log('cannot load config: $err');
    }

    return _api;
  }
}
