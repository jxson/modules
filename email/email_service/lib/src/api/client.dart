// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/http.dart' show Client;

const List<String> _kScopes = const <String>[
  'https://www.googleapis.com/auth/gmail.modify'
];

/// Returns an auto refreshing auth client for REST API requests.
///
/// NOTE: Some special attention may be needed for closing both the returned
/// client and the baseClient.
AutoRefreshingAuthClient client({
  String id,
  String secret,
  String token,
  DateTime expiry,
  String refreshToken,
}) {
  ClientId clientId = new ClientId(id, secret);
  AccessToken accessToken = new AccessToken('Bearer', token, expiry);
  AccessCredentials credentials =
      new AccessCredentials(accessToken, refreshToken, _kScopes);
  Client baseClient = new Client();
  return autoRefreshingClient(clientId, credentials, baseClient);
}
