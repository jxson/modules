// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:models/contact.dart';
import 'package:models/user.dart';
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

  group('Contact', () {
    group('primaryAddress', () {
      test('Should return null if contact contains no addresses', () {
        Contact contact = new Contact(
          user: new User(
            name: 'Coco',
            email: 'Coco@cu.te',
          ),
        );
        expect(contact.primaryAddress, null);
      });
      test('Should return first address if contact contains addresses', () {
        Contact contact = new Contact(
          user: new User(
            name: 'Coco',
            email: 'Coco@cu.te',
          ),
          addresses: <AddressEntry>[
            new AddressEntry(
              label: 'Work',
              city: 'Mountain View',
            ),
            new AddressEntry(
              label: 'Home',
              city: 'San Francisco',
            ),
          ],
        );
        expect(contact.primaryAddress, contact.addresses[0]);
      });
    });
    group('primaryEmail', () {
      test('Should return null if contact contains no emails', () {
        Contact contact = new Contact(
          user: new User(
            name: 'Coco',
            email: 'Coco@cu.te',
          ),
        );
        expect(contact.primaryEmail, null);
      });
      test('Should return first address if contact contains addresses', () {
        Contact contact = new Contact(
          user: new User(
            name: 'Coco',
            email: 'Coco@cu.te',
          ),
          emails: <EmailEntry>[
            new EmailEntry(
              label: 'Work',
              value: 'coco@work',
            ),
            new EmailEntry(
              label: 'Home',
              value: 'coco@home',
            ),
          ],
        );
        expect(contact.primaryEmail, contact.emails[0]);
      });
    });
    group('primaryPhoneNumber', () {
      test('Should return null if contact contains no phone numbers', () {
        Contact contact = new Contact(
          user: new User(
            name: 'Coco',
            email: 'Coco@cu.te',
          ),
        );
        expect(contact.primaryPhoneNumber, null);
      });
      test('Should return first phone number if contact contains phone numbers',
          () {
        Contact contact = new Contact(
          user: new User(
            name: 'Coco',
            email: 'Coco@cu.te',
          ),
          phoneNumbers: <PhoneEntry>[
            new PhoneEntry(
              label: 'Work',
              number: '13371337',
            ),
            new PhoneEntry(
              label: 'Home',
              number: '101010101',
            ),
          ],
        );
        expect(contact.primaryPhoneNumber, contact.phoneNumbers[0]);
      });
    });
    group('regionPreview', () {
      test('Should return null if contact has no primary address', () {
        Contact contact = new Contact(
          user: new User(
            name: 'Coco',
            email: 'Coco@cu.te',
          ),
        );
        expect(contact.regionPreview, null);
      });
      test(
          'Should return null if contact has primary address but no city nor region is given',
          () {
        Contact contact = new Contact(
          user: new User(
            name: 'Coco',
            email: 'Coco@cu.te',
          ),
          addresses: <AddressEntry>[
            new AddressEntry(
              country: 'USA',
              label: 'Work',
            )
          ],
        );
        expect(contact.regionPreview, null);
      });
      test(
          'Should return city if contact has primary address with a city and no region',
          () {
        Contact contact = new Contact(
          user: new User(
            name: 'Coco',
            email: 'Coco@cu.te',
          ),
          addresses: <AddressEntry>[
            new AddressEntry(
              city: 'Mountain View',
              country: 'USA',
              label: 'Work',
            )
          ],
        );
        expect(contact.regionPreview, 'Mountain View');
      });
      test(
          'Should return region if contact has primary address with a region and no city',
          () {
        Contact contact = new Contact(
          user: new User(
            name: 'Coco',
            email: 'Coco@cu.te',
          ),
          addresses: <AddressEntry>[
            new AddressEntry(
              region: 'CA',
              country: 'USA',
              label: 'Work',
            )
          ],
        );
        expect(contact.regionPreview, 'CA');
      });
      test(
          'Should return city, region if contact has primary address with a region and city',
          () {
        Contact contact = new Contact(
          user: new User(
            name: 'Coco',
            email: 'Coco@cu.te',
          ),
          addresses: <AddressEntry>[
            new AddressEntry(
              city: 'Mountain View',
              region: 'CA',
              country: 'USA',
              label: 'Work',
            )
          ],
        );
        expect(contact.regionPreview, 'Mountain View, CA');
      });
    });
  });
}
