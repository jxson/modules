// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/email.dart';
import 'package:widgets/email.dart';

void main() {
  testWidgets(
      'Test to see if tapping the CLOSE icon of a recipient chip '
      'will remove that entry from the recipient list',
      (WidgetTester tester) async {
    int removeRecipientTaps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new MaterialApp(
        routes: <String, WidgetBuilder>{
          '/next': (BuildContext context) {
            return new Text('Next');
          }
        },
        home: new Material(
          child: new RecipientInput(
            inputLabel: 'To:',
            recipientList: <Mailbox>[
              new Mailbox(
                displayName: 'Coco',
                address: 'coco@cu.te',
              )
            ],
            onRecipientsChanged: (List<Mailbox> recipients) {
              removeRecipientTaps++;
              expect(recipients.length, 0);
            },
          ),
        ),
      );
    }));

    expect(removeRecipientTaps, 0);
    await tester.tap(find.byWidgetPredicate(
        (Widget widget) => widget is Icon && widget.icon == Icons.cancel));
    expect(removeRecipientTaps, 1);
  });

  // TODO(dayang): Add in tests to test the "submit" logic on the text input
  // https://fuchsia.atlassian.net/browse/SO-105
  // This is blocked by Flutter Issue #6653
  // https://github.com/flutter/flutter/issues/6653
}
