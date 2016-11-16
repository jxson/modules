// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:tools/config.dart';

/// Generate OAuth refesh credentials and save them to email/config.json.
Future<Null> main(List<String> args) async {
  Config config = await Config.load();
  ClientId clientId = new ClientId(config.oauthId, config.oauthSecret);
  http.Client client = new http.Client();
  AccessCredentials credentials = await obtainAccessCredentialsViaUserConsent(
      clientId, Config.oauthScopes, client, _prompt);
  client.close();

  config.oauthToken = credentials.accessToken.data;
  config.oauthTokenExpiry = credentials.accessToken.expiry;
  config.oauthRefreshToken = credentials.refreshToken;

  await config.save();

  print('updated: ${config.file}');
}

void _prompt(String url) {
  print('Please go to the following URL and grant access:');
  print('  => $url');
  print('');
}
