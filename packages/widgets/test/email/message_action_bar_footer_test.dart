// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/email/mailbox.dart';
import 'package:models/email/message.dart';
import 'package:widgets/email/message_action_bar_footer.dart';

void main() {
  String profileUrl =
      'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg';
  testWidgets(
      'Test to see if tapping on the REPLY, REPLY ALL, and FORWARD buttons'
      'will call the appropiate callbacks', (WidgetTester tester) async {
    Message message = new Message(
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
    );

    int replyAlltaps = 0;
    int replyTaps = 0;
    int forwardTaps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new MessageActionBarFooter(
          message: message,
          onReplyAllMessage: (Message m) {
            expect(m, message);
            replyAlltaps++;
          },
          onReplyMessage: (Message m) {
            expect(m, message);
            replyTaps++;
          },
          onForwardMessage: (Message m) {
            expect(m, message);
            forwardTaps++;
          },
        ),
      );
    }));

    expect(replyAlltaps, 0);
    expect(replyTaps, 0);
    expect(forwardTaps, 0);
    await tester.tap(find.text('REPLY ALL'));
    expect(replyAlltaps, 1);
    expect(replyTaps, 0);
    expect(forwardTaps, 0);
    await tester.tap(find.text('REPLY'));
    expect(replyAlltaps, 1);
    expect(replyTaps, 1);
    expect(forwardTaps, 0);
    await tester.tap(find.text('FORWARD'));
    expect(replyAlltaps, 1);
    expect(replyTaps, 1);
    expect(forwardTaps, 1);
  });
}
