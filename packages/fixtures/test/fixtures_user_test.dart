// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:fixtures/fixtures.dart';
import 'package:models/user/user.dart';

void main() {
  Fixtures fixtures;

  setUp(() {
    fixtures = new Fixtures();
  });

  group('User user = Fixtures.user(...)', () {
    test('generates random user', () {
      User user = fixtures.user();

      expect(user.name, isNotEmpty);
      expect(user.email, contains(user.name.toLowerCase()));
    });
  });


  // Fixture<User> bob = new Fixture<User>({
  //   'name': 'Bob'
  // });

  // print('bob: $bob');
  // print('bob.name: ${bob.name}');
  // print('bob.email: ${bob.email}');

  // setUp(() {
  //
  // });
  //
  // test('', () {
  //   User bob = new Fixture<User>(name: 'Bob');
  // });
}
