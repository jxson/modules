// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/email/mailbox.dart';
import 'package:models/email/message.dart';
import 'package:models/email/thread.dart';
import 'package:widgets/email/thread_list_item.dart';

import 'helpers.dart';

void main() {
  String profileUrl =
      'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg';
  testWidgets(
      'Test to see if tapping on a ThreadListItem will call the'
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

    int taps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new ThreadListItem(
          key: threadListItemKey,
          thread: thread,
          onSelect: (Thread t) {
            expect(t, thread);
            taps++;
          },
        ),
      );
    }));

    expect(taps, 0);
    await tester.tap(find.byKey(threadListItemKey));
    expect(taps, 1);
  });

  testWidgets(
      'Test to see if swiping right will call the appropiate archive callback '
      'with given Thread', (WidgetTester tester) async {
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

    int swipes = 0;

    Key threadListItemKey = new UniqueKey();

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new ThreadListItem(
          key: threadListItemKey,
          thread: thread,
          onArchive: (Thread t) {
            expect(t, thread);
            swipes++;
          },
        ),
      );
    }));

    expect(swipes, 0);

    //Swipe Left
    await swipeDissmissable(
      tester: tester,
      key: threadListItemKey,
      direction: DismissDirection.endToStart,
    );

    expect(swipes, 1);
  });

  testWidgets(
      'Test to see if swiping left will call the appropiate archive callback '
      'with given Thread', (WidgetTester tester) async {
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

    int swipes = 0;

    Key threadListItemKey = new UniqueKey();

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new ThreadListItem(
          key: threadListItemKey,
          thread: thread,
          onArchive: (Thread t) {
            expect(t, thread);
            swipes++;
          },
        ),
      );
    }));

    expect(swipes, 0);

    //Swipe Left
    await swipeDissmissable(
      tester: tester,
      key: threadListItemKey,
      direction: DismissDirection.startToEnd,
    );

    expect(swipes, 1);
  });
}
