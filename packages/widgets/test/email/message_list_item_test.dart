// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/email/message.dart';
import 'package:widgets/email/message_content.dart';
import 'package:widgets/email/message_list_item.dart';

void main() {
  String profileUrl =
      'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg';
  testWidgets(
      'Test to see if tapping the header for a MessageListItem will call the'
      'appropiate callback with given Message', (WidgetTester tester) async {
    Message message = new Message(
      sender: 'Coco Yang',
      recipientList: <String>['David Yang'],
      senderProfileUrl: profileUrl,
      subject: 'Feed Me!!!',
      text: "Woof Woof. I'm so hungry. You need to feed me!",
      timestamp: new DateTime.now(),
      isRead: true,
    );

    int taps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new MessageListItem(
          message: message,
          onHeaderTap: (Message m) {
            expect(m, message);
            taps++;
          },
        ),
      );
    }));

    expect(taps, 0);
    await tester.tap(find.byType(ListItem));
    expect(taps, 1);
  });

  testWidgets(
      'Test to see if the MessageContent is not shown if a MessageListItem'
      'is not expanded', (WidgetTester tester) async {
    Message message = new Message(
      sender: 'Coco Yang',
      recipientList: <String>['David Yang'],
      senderProfileUrl: profileUrl,
      subject: 'Feed Me!!!',
      text: "Woof Woof. I'm so hungry. You need to feed me!",
      timestamp: new DateTime.now(),
      isRead: true,
    );

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new MessageListItem(
          message: message,
          isExpanded: false,
        ),
      );
    }));

    expect(find.byType(MessageContent), findsNothing);
  });

  testWidgets(
      'Test to see if the MessageContent is shown if a MessageListItem'
      'is expanded', (WidgetTester tester) async {
    Message message = new Message(
      sender: 'Coco Yang',
      recipientList: <String>['David Yang'],
      senderProfileUrl: profileUrl,
      subject: 'Feed Me!!!',
      text: "Woof Woof. I'm so hungry. You need to feed me!",
      timestamp: new DateTime.now(),
      isRead: true,
    );

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new MessageListItem(
          message: message,
          isExpanded: true,
        ),
      );
    }));

    expect(find.byType(MessageContent), findsOneWidget);
  });
}
