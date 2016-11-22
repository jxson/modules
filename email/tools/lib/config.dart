// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
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

  /// The file object for email/config.json.
  File file;

  /// The value from oauth_id.
  String oauthId;

  /// The value from oauth_secret.
  String oauthSecret;

  /// The value for oauth_token.
  String oauthToken;

  /// The value for oauth_token_expiry.
  DateTime oauthTokenExpiry;

  /// The value for oauth_refresh_token.
  String oauthRefreshToken;

  /// The value for youtube API key.
  String youtubeApiKey;

  /// Utilitiy for managing the email/config.json file.
  Config({
    this.file,
    this.oauthId,
    this.oauthSecret,
    this.youtubeApiKey,
  });

  /// Read the config file and load it's values.
  static Future<Config> load() async {
    File file = new File(filename);

    if (!(await file.exists())) {
      throw new StateError('''
Config file does not exist:

    $file
      ''');
    }

    String contents = await file.readAsString();
    dynamic data = JSON.decode(contents);

    if (data['oauth_id'] == null || data['oauth_secret'] == null) {
      String message = '''
Config keys for "oauth_id" and "oauth_secret" are required in file:

    $file
      ''';
      throw new StateError(message);
    }

    Config config = new Config(
      file: file,
      oauthId: data['oauth_id'],
      oauthSecret: data['oauth_secret'],
      youtubeApiKey: data['youtube_api_key'],
    );

    return config;
  }

  /// Create a [Map] for use in JSON encoding.
  Map<String, String> toJSON() {
    Map<String, String> json = new Map<String, String>();

    json['oauth_id'] = oauthId;
    json['oauth_secret'] = oauthSecret;
    json['oauth_token'] = oauthToken;
    json['oauth_token_expiry'] = oauthTokenExpiry.toString();
    json['oauth_refresh_token'] = oauthRefreshToken;
    json['youtube_api_key'] = youtubeApiKey;

    return json;
  }

  /// Save the current configuration values to [this.file].
  Future<Null> save() async {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    Map<String, String> json = this.toJSON();
    String data = encoder.convert(json);
    await file.writeAsString(data);
  }
}
