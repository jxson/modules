// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:fixtures/fixtures.dart';

void main() {
  group('Name name = new Name();', () {
    test('generates a random name', () {
      Name name = new Name();

      expect(name.id, isNotEmpty);
      expect(name.toString(), isNotEmpty);
    });
  });

  group('Name name = new Name(<string>);', () {
    test('Names with the same values are identical', () {
      Name bob1 = new Name('Bob');
      Name bob2 = new Name('Bob');

      expect(bob1.id, equals(bob2.id));
      expect('$bob1', equals('$bob2'));
      expect(bob1, equals(bob2));
    });
  });
}
