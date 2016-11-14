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
  String identifier = await Config.get('oauth_id');
  String secret = await Config.get('oauth_secret');

  ClientId id = new ClientId(identifier, secret);
  http.Client client = new http.Client();
  List<String> scopes = <String>[
    'https://www.googleapis.com/auth/gmail.modify'
  ];

  AccessCredentials credentials =
      await obtainAccessCredentialsViaUserConsent(id, scopes, client, _prompt);
  client.close();

  String source = '''
// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

const String _kOauthID =
    '$identifier';
const String _kOauthSecret = '$secret';
const String _kTokenData =
    '${credentials.accessToken.data}';
final DateTime _kTokenExpiry = DateTime.parse('${credentials.accessToken.expiry}');
const String _kRefreshToken = '${credentials.refreshToken}';
const List<String> _kScopes = const <String>[
  'https://www.googleapis.com/auth/gmail.modify'
];

/// Returns an auto refreshing auth client for REST API requests.
///
/// NOTE: Some special attention may be needed for closing both the returned
/// client and the baseClient.
AutoRefreshingAuthClient client() {
  AccessToken token = new AccessToken('Bearer', _kTokenData, _kTokenExpiry);
  AccessCredentials credentials =
      new AccessCredentials(token, _kRefreshToken, _kScopes);
  ClientId id = new ClientId(_kOauthID, _kOauthSecret);
  http.Client baseClient = new http.Client();
  return autoRefreshingClient(id, credentials, baseClient);
}
''';

  String cwd = path.normalize(path.absolute('..'));
  String dirname = path.join(cwd, 'service', 'lib', 'src', 'api');
  Directory directory = new Directory(dirname);
  if (!(await directory.exists())) {
    await directory.create(recursive: true);
  }

  String filename = path.join(dirname, 'client.dart');
  File file = new File(filename);
  if (!(await file.exists())) {
    await file.writeAsString('');
  }

  await file.writeAsString(source);

  print('created: $file');
}

void _prompt(String url) {
  print('Please go to the following URL and grant access:');
  print('  => $url');
  print('');
}
