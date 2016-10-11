// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:models/contact.dart';
import 'package:test/test.dart';

void main() {
  group('EmailEntry', () {
    test('toString()', () {
      EmailEntry email = new EmailEntry(
        label: 'Personal',
        value: 'coco@puppy.cute',
      );
      expect(email.toString(), 'coco@puppy.cute');
    });
  });

  group('AddressEntry', () {
    test('toString()', () {
      AddressEntry addressEntry = new AddressEntry(
        street: '1842 N Shoreline Blvd',
        city: 'Mountain View',
        region: 'California',
        postalCode: '94043',
        country: 'United States of America',
        countryCode: 'US',
      );
      expect(
          addressEntry.toString(),
          '1842 N Shoreline Blvd, '
          'Mountain View, California, 94043, United States of America, US');
    });
  });

  group('SocialNetworkEntry', () {
    test('toString()', () {
      SocialNetworkEntry socialNetworkEntry = new SocialNetworkEntry(
        type: SocialNetworkType.twitter,
        account: 'google',
      );
      expect(socialNetworkEntry.toString(), 'google');
    });
  });
}
