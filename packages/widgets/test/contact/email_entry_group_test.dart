// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/contact.dart';
import 'package:widgets/contact.dart';

void main() {
  testWidgets(
      'Test to see if tapping on a single email entry '
      'will call the appropriate callbacks', (WidgetTester tester) async {
    List<EmailEntry> emails = <EmailEntry>[
      new EmailEntry(
        label: 'Work',
        value: 'coco@work',
      ),
      new EmailEntry(
        label: 'Home',
        value: 'coco@home',
      ),
    ];

    int workEmailTaps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new EmailEntryGroup(
          emailEntries: emails,
          onSelectEmailEntry: (EmailEntry entry) {
            workEmailTaps++;
            expect(entry, emails[0]);
          },
        ),
      );
    }));

    expect(workEmailTaps, 0);
    await tester.tap(find.text(emails[0].label));
    expect(workEmailTaps, 1);
  });
}
