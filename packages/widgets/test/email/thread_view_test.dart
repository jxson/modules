// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/email/message.dart';
import 'package:models/email/thread.dart';
import 'package:widgets/email/thread_view.dart';
import 'package:widgets/email/message_list_item.dart';

void main() {
  String profileUrl =
      'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg';
  testWidgets(
      'Test to see if tapping on a Message inside a ThreadView will call the'
      'appropiate callback with given Message', (WidgetTester tester) async {
    Thread thread = new Thread(
      id: '1',
      messages: <Message>[
        new Message(
          sender: 'Coco Yang',
          recipientList: <String>['David Yang'],
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
        child: new ThreadView(
          thread: thread,
          onForwardMessage: (Message m) {},
          onReplyMessage: (Message m) {},
          onReplyAllMessage: (Message m) {},
          onSelectMessage: (Message m) {
            expect(m, thread.messages[0]);
            taps++;
          },
        ),
      );
    }));

    expect(taps, 0);
    await tester.tap(find.byType(MessageListItem));
    expect(taps, 1);
  });

  testWidgets(
      'Test to make sure that ThreadView will render a MessageListItem for every '
      'message in the thread', (WidgetTester tester) async {
    Thread thread = new Thread(
      messages: <Message>[
        new Message(
          id: '1',
          sender: 'Coco Yang',
          recipientList: <String>['David Yang'],
          senderProfileUrl: profileUrl,
          subject: 'Feed Me!!!',
          text: "Woof Woof. I'm so hungry. You need to feed me!",
          timestamp: new DateTime.now(),
          isRead: true,
        ),
        new Message(
          id: '2',
          sender: 'Coco Yang',
          recipientList: <String>['David Yang'],
          senderProfileUrl: profileUrl,
          subject: 'Feed Me!!!',
          text: "Woof Woof. I'm so hungry. You need to feed me!",
          timestamp: new DateTime.now(),
          isRead: true,
        ),
      ],
    );

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new ThreadView(
          onForwardMessage: (Message m) {},
          onReplyMessage: (Message m) {},
          onReplyAllMessage: (Message m) {},
          thread: thread,
        ),
      );
    }));

    expect(find.byType(MessageListItem), findsNWidgets(2));
  });

  testWidgets('Test to see the footer widget will be rendered if given',
      (WidgetTester tester) async {
    Thread thread = new Thread(
      id: '1',
      messages: <Message>[
        new Message(
          sender: 'Coco Yang',
          recipientList: <String>['David Yang'],
          senderProfileUrl: profileUrl,
          subject: 'Feed Me!!!',
          text: "Woof Woof. I'm so hungry. You need to feed me!",
          timestamp: new DateTime.now(),
          isRead: true,
        ),
      ],
    );

    Key footerKey = new UniqueKey();

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new ThreadView(
          onForwardMessage: (Message m) {},
          onReplyMessage: (Message m) {},
          onReplyAllMessage: (Message m) {},
          thread: thread,
          footer: new Text('End', key: footerKey),
        ),
      );
    }));

    expect(find.byKey(footerKey), findsOneWidget);
  });

  testWidgets('Test to see the header widget will be rendered if given',
      (WidgetTester tester) async {
    Thread thread = new Thread(
      id: '1',
      messages: <Message>[
        new Message(
          sender: 'Coco Yang',
          recipientList: <String>['David Yang'],
          senderProfileUrl: profileUrl,
          subject: 'Feed Me!!!',
          text: "Woof Woof. I'm so hungry. You need to feed me!",
          timestamp: new DateTime.now(),
          isRead: true,
        ),
      ],
    );

    Key headerKey = new UniqueKey();

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new ThreadView(
          onForwardMessage: (Message m) {},
          onReplyMessage: (Message m) {},
          onReplyAllMessage: (Message m) {},
          thread: thread,
          header: new Text('Start', key: headerKey),
        ),
      );
    }));

    expect(find.byKey(headerKey), findsOneWidget);
  });
}
