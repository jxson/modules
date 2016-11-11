// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:tools/config.dart';

/// TODO(jasoncampbell): add documentation for this!
Future<Null> main(List<String> args) async {
  String identifier = await Config.get('oauth_id');
  String secret = await Config.get('oauth_secret');

  ClientId id = new ClientId(identifier, secret);
  http.Client client = new http.Client();
  List<String> scopes = <String>[
    'https://www.googleapis.com/auth/gmail.modify'
  ];

  AccessCredentials credentials = await obtainAccessCredentialsViaUserConsent(id, scopes, client, prompt);

  print('SUCCESS $credentials');
  client.close();
}

void prompt(String url) {
  print('Please go to the following URL and grant access:');
  print('  => $url');
  print('');
}
