// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/email/mailbox.dart';
import 'package:models/email/message.dart';
import 'package:models/email/thread.dart';
import 'package:widgets/email/thread_action_bar_header.dart';

void main() {
  String profileUrl =
      'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg';
  testWidgets(
      'Test to see if tapping on the CLOSE, ARCHIVE, DELETE, and MORE ACTIONS'
      'buttons will call the appropiate callbacks',
      (WidgetTester tester) async {
    Thread thread = new Thread(
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

    int closeTaps = 0;
    int archiveTaps = 0;
    int deleteTaps = 0;
    int moreActionsTaps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new ThreadActionBarHeader(
          thread: thread,
          onArchive: (Thread t) {
            expect(t, thread);
            archiveTaps++;
          },
          onClose: (Thread t) {
            expect(t, thread);
            closeTaps++;
          },
          onDelete: (Thread t) {
            expect(t, thread);
            deleteTaps++;
          },
          onMoreActions: (Thread t) {
            expect(t, thread);
            moreActionsTaps++;
          },
        ),
      );
    }));

    expect(archiveTaps, 0);
    expect(closeTaps, 0);
    expect(deleteTaps, 0);
    expect(moreActionsTaps, 0);
    await tester.tap(find.byWidgetPredicate(
        (Widget widget) => widget is Icon && widget.icon == Icons.archive));
    expect(archiveTaps, 1);
    expect(closeTaps, 0);
    expect(deleteTaps, 0);
    expect(moreActionsTaps, 0);
    await tester.tap(find.byWidgetPredicate(
        (Widget widget) => widget is Icon && widget.icon == Icons.close));
    expect(archiveTaps, 1);
    expect(closeTaps, 1);
    expect(deleteTaps, 0);
    expect(moreActionsTaps, 0);
    await tester.tap(find.byWidgetPredicate(
        (Widget widget) => widget is Icon && widget.icon == Icons.delete));
    expect(archiveTaps, 1);
    expect(closeTaps, 1);
    expect(deleteTaps, 1);
    expect(moreActionsTaps, 0);
    await tester.tap(find.byWidgetPredicate(
        (Widget widget) => widget is Icon && widget.icon == Icons.more_vert));
    expect(archiveTaps, 1);
    expect(closeTaps, 1);
    expect(deleteTaps, 1);
    expect(moreActionsTaps, 1);
  });
}
