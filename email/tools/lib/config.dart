// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:io';

import './resolve.dart';

/// Configuration tooling.
class Config {
  /// The path to the config file.
  static String filename = resolve('config.json');
  /// The OAuth scopes.
  static List<String> oauthScopes = <String>[
    'https://www.googleapis.com/auth/gmail.modify'
  ];

  File file;
  String oauthId;
  String oauthSecret;
  String oauthToken;
  DateTime oauthTokenExpiry;
  String oauthRefreshToken;

  Config({
    this.file,
    this.oauthId,
    this.oauthSecret,
  });

  static Future<Config> load() async {
    File file = new File(filename);

    if (!(await file.exists())) {
      // STATE ERROR
    }

    String contents = await file.readAsString();
    dynamic data = JSON.decode(contents);
    String oauthId = data['oauth_id'];
    String oauthSecret = data['oauth_secret'];

    Config config = new Config(
      file: file,
      oauthId: oauthId,
      oauthSecret: oauthSecret,
    );

    return config;
  }


  Map toJSON() {
    Map<String, String> json = new Map<String, String>();

    json['oauth_id'] = oauthId;
    json['oauth_secret'] = oauthSecret;
    json['oauth_token'] = oauthToken;
    json['oauth_token_expiry'] = oauthTokenExpiry.toString();
    json['oauth_refresh_token'] = oauthRefreshToken;

    return json;
  }

  Future<Null> save() async {
    String data = JSON.encode(this.toJSON());
    await file.writeAsString(data);
  }
}
