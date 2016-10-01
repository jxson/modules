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

  group('fixtures.user(...)', () {
    test('no args', () {
      User user = fixtures.user();

      expect(user.id, isNotNull, reason: 'id should be set');
      expect(user.name, isNotEmpty, reason: 'name should not be empty');
      expect(user.email, isNotEmpty, reason: 'email should be set');
      expect(user.givenName, isNotEmpty, reason: 'givenName should be set');
      expect(user.familyName, isNotEmpty, reason: 'familyName should be set');
      expect(user.picture, isNotEmpty, reason: 'picture should be set');
      expect(user.locale, equals('en'), reason: 'locale should default to en');
    });

    test('with optional args', () {
      User alice = fixtures.user(name: 'Alice');
      expect(alice.name, equals('Alice'));
    });

    test('generates unique users', () {
      User one = fixtures.user();
      User two = fixtures.user();

      expect(one, isNot(equals(two)));
      expect(one.name, isNot(two.name));
      expect(one.email, isNot(two.email));
    });

    test('generates users with email sequences', () {
      // NOTE: fixtures is defined here, instead of in setUp(...) to prevent
      // other tests from impacting the email sequences.
      Fixtures fixtures = new Fixtures();
      User first = fixtures.user(name: 'Bob');
      User last = fixtures.user(name: 'Alice');

      expect(first.email, contains('1'));
      expect(last.email, contains('2'));
    });
  });
}
