// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/contact.dart';
import 'package:models/user.dart';
import 'package:widgets/contact.dart';

void main() {
  testWidgets(
      'Test to see if tapping on a single phone entry '
      'will call the appropiate callbacks', (WidgetTester tester) async {
    Contact contact = new Contact(
      user: new User(
        name: 'Coco Yang',
        email: 'coco@cu.te',
      ),
      phoneNumbers: <PhoneEntry>[
        new PhoneEntry(
          label: 'Work',
          number: '13371337',
        ),
        new PhoneEntry(
          label: 'Home',
          number: '10101010',
        ),
      ],
    );

    int workPhoneTaps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new PhoneEntryGroup(
          contact: contact,
          onSelectPhoneEntry: (PhoneEntry phone) {
            workPhoneTaps++;
            expect(phone, contact.phoneNumbers[0]);
          },
        ),
      );
    }));

    expect(workPhoneTaps, 0);
    await tester.tap(find.text('Work'));
    expect(workPhoneTaps, 1);
  });
}
