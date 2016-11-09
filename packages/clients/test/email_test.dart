// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:clients/email.dart';
import "package:http/http.dart" as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:test/test.dart';

void main() {
  test("BLAH", () async {
    String identifier = '';
    String secret = '';
    ClientId id = new ClientId(identifier, secret);
    http.Client client = new http.Client();
    List<String> scopes = [
      'https://www.googleapis.com/auth/gmail.modify'
    ];

    await obtainAccessCredentialsViaUserConsent(id, scopes, client, prompt)
      .then((AccessCredentials credentials) {
        print('credentials: $credentials');
        expect(credentials, isNotNull);
        client.close();
      });
  });
}

void prompt(String url) {
  print("Please go to the following URL and grant access:");
  print("  => $url");
  print("");
}
