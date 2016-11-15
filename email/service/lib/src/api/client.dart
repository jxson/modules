// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

const String _kOauthID = '';
const String _kOauthSecret = '';
const String _kTokenData = '';
final DateTime _kTokenExpiry = DateTime.parse('2016-11-15 00:21:53.978297Z');
const String _kRefreshToken = '';
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
