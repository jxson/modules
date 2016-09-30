// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:fixtures/fixtures.dart';

const int _kThreshold = 1000;

void main() {
  group('Fixtures.name()', () {
    Fixtures fixtures;

    setUp(() {
      fixtures = new Fixtures(threshold: _kThreshold);
    });

    test('generates random names.', () {
      Name n1 = fixtures.name();
      Name n2 = fixtures.name();

      expect(n1, isNot(equals(n2)));
      expect(n1.toString(), isNot(equals(n2.toString())));
    });

    test('generates up to "$_kThreshold" unique names.', () {
      Set<Name> names = new Set<Name>();

      for (int i = 0; i < fixtures.threshold; i++) {
        Name name = fixtures.name();

        if (!names.add(name)) {
          fail('Non unique name $name generated at index $i');
        }
      }
    });
  });
}
