// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/contact.dart';
import 'package:widgets/contact.dart';

void main() {
  testWidgets(
      'Test to see if tapping on a single address entry '
      'will call the appropriate callbacks', (WidgetTester tester) async {
    List<AddressEntry> addresses = <AddressEntry>[
      new AddressEntry(
        label: 'Work',
        street: 'Work Street',
      ),
      new AddressEntry(
        label: 'Home',
        street: 'Home Street',
      ),
    ];

    int workAddressTaps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new AddressEntryGroup(
          addressEntries: addresses,
          onSelectAddressEntry: (AddressEntry entry) {
            workAddressTaps++;
            expect(entry, addresses[0]);
          },
        ),
      );
    }));

    expect(workAddressTaps, 0);
    await tester.tap(find.text(addresses[0].label));
    expect(workAddressTaps, 1);
  });
}
