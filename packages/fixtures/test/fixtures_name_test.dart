// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:fixtures/fixtures.dart';

const int _kThreshold = 1000;

void main() {
  Fixtures fixtures;

  setUp(() {
    fixtures = new Fixtures();
  });

  group('fixtures.name()', () {
    test('generates random names.', () {
      Name first = fixtures.name();
      Name second = fixtures.name();

      expect(first, isNot(second), reason: 'Generated names should not be the same.');
    });

    test('can generate up to "$_kThreshold" unique names', () {
      Fixtures fixtures = new Fixtures(threshold: _kThreshold);
      Set<Name> names = new Set<Name>();

      for (int i = 0; i < fixtures.threshold; i++) {
        Name name = fixtures.name();

        if (!names.add(name)) {
          fail('Non unique name $name generated at index $i');
        }
      }
    });

    test('create a specific name', () {
      String value = 'Jason Campbell';
      Name jason = fixtures.name(value);

      expect('$jason', equals(value));
    });

    test('threshold limit on unique Names', () {
      Fixtures fixtures = new Fixtures(threshold: 1);
      Name fist = fixtures.name();

      expect(() => fixtures.name(), throwsA(new isInstanceOf<FixturesError>()));
    });
  });
}
