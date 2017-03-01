// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:tools/config.dart';
import 'package:tools/resolve.dart';

/// Generate OAuth refesh credentials and save them to email/config.json.
Future<Null> main(List<String> args) async {
  String filename = resolve('config.json');
  Config config = await Config.read(filename);

  if (config.has('oauth_id') == false ||
      config.has('oauth_secret') == false) {
    String message = '''
Config keys for "oauth_id" and "oauth_secret" are required in file:

  $filename
    ''';
    throw new StateError(message);
  }

  ClientId clientId =
      new ClientId(config.get('oauth_id'), config.get('oauth_secret'));
  http.Client client = new http.Client();
  AccessCredentials credentials = await obtainAccessCredentialsViaUserConsent(
      clientId, config.scopes, client, _prompt);
  client.close();

  config.put('id_token', credentials.idToken);
  config.put('oauth_token', credentials.accessToken.data);
  config.put('oauth_token_expiry', credentials.accessToken.expiry.toString());
  config.put('oauth_refresh_token', credentials.refreshToken);
  await config.save();

  print('updated: ${config.file}');
}

void _prompt(String url) {
  print('Please go to the following URL and grant access:');
  print('  => $url');
  print('');
}
