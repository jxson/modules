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
      'Test to see if tapping on the call, text, email'
      'buttons will call the appropiate callbacks',
      (WidgetTester tester) async {
    Contact contact = new Contact(
      user: new User(
        name: 'Coco Yang',
        email: 'coco@cu.te',
      ),
      addresses: <AddressEntry>[
        new AddressEntry(
          city: 'Mountain View',
          region: 'CA',
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
          number: '13371337',
        ),
      ],
    );

    int callTaps = 0;
    int emailTaps = 0;
    int textTaps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new ContactDetails(
            contact: contact,
            onCall: (PhoneEntry phone) {
              callTaps++;
              expect(phone, contact.phoneNumbers[0]);
            },
            onText: (PhoneEntry phone) {
              textTaps++;
              expect(phone, contact.phoneNumbers[0]);
            },
            onEmail: (EmailEntry email) {
              emailTaps++;
              expect(email, contact.emails[0]);
            }),
      );
    }));

    expect(callTaps, 0);
    expect(emailTaps, 0);
    expect(textTaps, 0);
    await tester.tap(find
        .byWidgetPredicate(
            (Widget widget) => widget is Icon && widget.icon == Icons.phone)
        .first);
    expect(callTaps, 1);
    expect(emailTaps, 0);
    expect(textTaps, 0);
    await tester.tap(find
        .byWidgetPredicate(
            (Widget widget) => widget is Icon && widget.icon == Icons.message)
        .first);
    expect(callTaps, 1);
    expect(emailTaps, 0);
    expect(textTaps, 1);
    await tester.tap(find
        .byWidgetPredicate(
            (Widget widget) => widget is Icon && widget.icon == Icons.email)
        .first);
    expect(callTaps, 1);
    expect(emailTaps, 1);
    expect(textTaps, 1);
  });
  testWidgets(
      'Test to see if tapping on the call, text, email buttons will not do '
      'anything if the contact does not have the given fields',
      (WidgetTester tester) async {
    Contact contact = new Contact(
      user: new User(
        name: 'Coco Yang',
        email: 'coco@cu.te',
      ),
    );

    int callTaps = 0;
    int emailTaps = 0;
    int textTaps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new ContactDetails(
          contact: contact,
          onCall: (PhoneEntry phone) {
            callTaps++;
            expect(phone, contact.phoneNumbers[0]);
          },
          onText: (PhoneEntry phone) {
            textTaps++;
            expect(phone, contact.phoneNumbers[0]);
          },
          onEmail: (EmailEntry email) {
            emailTaps++;
            expect(email, contact.emails[0]);
          },
        ),
      );
    }));

    expect(callTaps, 0);
    expect(emailTaps, 0);
    expect(textTaps, 0);
    await tester.tap(find
        .byWidgetPredicate(
            (Widget widget) => widget is Icon && widget.icon == Icons.phone)
        .first);
    expect(callTaps, 0);
    expect(emailTaps, 0);
    expect(textTaps, 0);
    await tester.tap(find
        .byWidgetPredicate(
            (Widget widget) => widget is Icon && widget.icon == Icons.message)
        .first);
    expect(callTaps, 0);
    expect(emailTaps, 0);
    expect(textTaps, 0);
    await tester.tap(find
        .byWidgetPredicate(
            (Widget widget) => widget is Icon && widget.icon == Icons.email)
        .first);
    expect(callTaps, 0);
    expect(emailTaps, 0);
    expect(textTaps, 0);
  });
}
