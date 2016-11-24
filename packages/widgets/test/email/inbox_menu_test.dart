// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';
import 'package:widgets/email.dart';

void main() {
  testWidgets(
      'Test to see if tapping on a LabelListItem inside a LabelGroupList '
      'will call the appropiate callback', (WidgetTester tester) async {
    LabelGroup labelGroup1 = new LabelGroup(
      labels: <Label>[
        new Label(name: 'Primary'),
        new Label(name: 'Archived'),
      ],
    );
    LabelGroup labelGroup2 = new LabelGroup(
      name: 'Labels',
      labels: <Label>[
        new Label(name: 'Advertisements'),
        new Label(name: 'Travel'),
        new Label(name: 'Finance'),
      ],
    );
    User user = new User(
      name: 'Coco Yang',
      email: 'littlePuppyCoco@puppy.cute',
      picture:
          'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg',
    );

    int taps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new InboxMenu(
          labelGroups: <LabelGroup>[labelGroup1, labelGroup2],
          onSelectLabel: (Label f) {
            expect(f, labelGroup2.labels[0]);
            taps++;
          },
          user: user,
        ),
      );
    }));

    expect(taps, 0);
    await tester.tap(find.text('Advertisements'));
    expect(taps, 1);
  });
}
