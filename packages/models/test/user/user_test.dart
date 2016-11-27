// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:models/user.dart';
import 'package:fixtures/fixtures.dart';
import 'package:test/test.dart';

void main() {
  Fixtures fixtures = new Fixtures();

  test('User JSON encode/decode', () {
    User user = fixtures.user();

    String encoded = JSON.encode(user);
    Map<String, dynamic> json = JSON.decode(encoded);
    User hydrated = new User.fromJson(json);

    expect(hydrated.id, equals(user.id));
    expect(hydrated.email, equals(user.email));
    expect(hydrated.name, equals(user.name));
    expect(hydrated.picture, equals(user.picture));
  });
}
