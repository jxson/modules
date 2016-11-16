// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:tools/config.dart';

Future<Null> main(List<String> args) async {
  Config config = await Config.load();
  String identifier = config.get('oauth_id');
  String secret = config.get('oauth_secret');

  ClientId id = new ClientId(identifier, secret);
  http.Client client = new http.Client();
  List<String> scopes = <String>[
    'https://www.googleapis.com/auth/gmail.modify'
  ];

  AccessCredentials credentials =
      await obtainAccessCredentialsViaUserConsent(id, scopes, client, _prompt);
  client.close();

  config.put('oauth_token', credentials.accessToken.data);
  config.put('oauth_token_expiry', credentials.accessToken.expiry);
  config.put('oauth_refresh_token', credentials.accessToken.expiry);

  await config.save();

  print('updated: ${config.file}');
}

void _prompt(String url) {
  print('Please go to the following URL and grant access:');
  print('  => $url');
  print('');
}
