// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/contact.dart';
import 'package:widgets/contact.dart';

void main() {
  testWidgets(
      'Test to see if tapping on a ContactListItem will call the'
      'appropiate callback with given Contact', (WidgetTester tester) async {
    Key contactListItemKey = new UniqueKey();
    Contact contact = new Contact(
      displayName: 'Coco Yang',
    );

    int taps = 0;

    await tester.pumpWidget(new Material(
      child: new ContactListItem(
        key: contactListItemKey,
        contact: contact,
        onSelect: (Contact c) {
          expect(c, contact);
          taps++;
        },
      ),
    ));

    expect(taps, 0);
    await tester.tap(find.byKey(contactListItemKey));
    expect(taps, 1);
  });
}
