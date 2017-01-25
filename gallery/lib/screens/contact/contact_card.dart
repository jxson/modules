// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:models/contact.dart';
import 'package:models/user.dart';
import 'package:widgets/contact.dart';

/// Contact Card page
class ContactCardScreen extends StatelessWidget {
  /// Creates a [ContactCardScreen] instance.
  ContactCardScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Contact contact = new Contact(
      user: new User(
        name: 'Coco Yang',
        email: 'coco@cu.te',
        familyName: 'Yang',
        givenName: 'Coco',
        picture:
            'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg',
      ),
      addresses: <AddressEntry>[
        new AddressEntry(
          street: '517 Fuchsia Drive',
          city: 'Mountain View',
          region: 'CA',
          country: 'United States',
        )
      ],
      emails: <EmailEntry>[
        new EmailEntry(
          label: 'Work',
          value: 'coco@cu.te',
        ),
      ],
      phoneNumbers: <PhoneEntry>[
        new PhoneEntry(
          label: 'Work',
          number: '1-800-337-1337',
        ),
        new PhoneEntry(
          label: 'Home',
          number: '1-337-337-0000',
        ),
        new PhoneEntry(
          number: '1-456-337-0000',
        ),
      ],
    );
    // Apply the ContactTheme to the ContactCard Widget
    return new Theme(
      data: contactTheme,
      isMaterialAppTheme: false,
      child: new ContactCard(
        contact: contact,
      ),
    );
  }
}
