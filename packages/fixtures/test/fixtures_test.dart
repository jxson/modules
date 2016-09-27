// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:fixtures/fixtures.dart';
import 'package:models/user/user.dart';

void main() {
  User bob = Fixtures.user(
    name: 'Bob'
  );

  // Fixture<User> bob = new Fixture<User>({
  //   'name': 'Bob'
  // });

  print('bob: $bob');
  print('bob.name: ${bob.name}');
  print('bob.email: ${bob.email}');

  // setUp(() {
  //
  // });
  //
  // test('', () {
  //   User bob = new Fixture<User>(name: 'Bob');
  // });
}
