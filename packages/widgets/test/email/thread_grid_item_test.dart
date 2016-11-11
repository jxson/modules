// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/email.dart';
import 'package:widgets/email.dart';

void main() {
  String profileUrl =
      'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg';
  testWidgets(
      'Test to see if tapping on a ThreadGridItem will call the'
      'appropiate callback with given Thread', (WidgetTester tester) async {
    Key threadListItemKey = new UniqueKey();
    Thread thread = new Thread(
      id: '1',
      messages: <Message>[
        new Message(
          sender: new Mailbox(
            address: 'cocoyang@cu.te',
            displayName: 'Coco Yang',
          ),
          recipientList: <Mailbox>[
            new Mailbox(
              address: 'david@ya.ng',
              displayName: 'David Yang',
            )
          ],
          senderProfileUrl: profileUrl,
          subject: 'Feed Me!!!',
          text: "Woof Woof. I'm so hungry. You need to feed me!",
          timestamp: new DateTime.now(),
          isRead: true,
        ),
      ],
    );

    int selectTaps = 0;
    int moreActionsTaps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new ThreadGridItem(
          key: threadListItemKey,
          thread: thread,
          onSelect: (Thread t) {
            expect(t, thread);
            selectTaps++;
          },
          onMoreActions: (Thread t) {
            expect(t, thread);
            moreActionsTaps++;
          },
        ),
      );
    }));

    expect(selectTaps, 0);
    expect(moreActionsTaps, 0);
    await tester.tap(find.byKey(threadListItemKey));
    expect(selectTaps, 1);
    expect(moreActionsTaps, 0);
    await tester.tap(find.byWidgetPredicate(
        (Widget widget) => widget is Icon && widget.icon == Icons.more_vert));
    expect(selectTaps, 1);
    expect(moreActionsTaps, 1);
  });
}
