// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:models/email/message.dart';
import 'package:models/email/thread.dart';
import 'package:test/test.dart';

void main() {
  test(
      'getSubject() should return message of the first subject in the'
      'thread', () {
    Thread thread = new Thread(
      id: '1',
      messages: <Message>[
        new Message(
          sender: 'Coco Yang',
          recipientList: <String>['David Yang'],
          subject: 'Feed Me!!!',
          text: "Woof Woof. I'm so hungry. You need to feed me!",
          timestamp: new DateTime.now(),
          isRead: true,
        ),
        new Message(
          sender: 'Coco Yang',
          recipientList: <String>['David Yang'],
          subject: 'PLEAZE Feed Me!!!',
          text: "Woof Woof. I'm so hungry. You need to feed me!",
          timestamp: new DateTime.now(),
          isRead: true,
        ),
      ],
    );
    expect(thread.getSubject(), 'Feed Me!!!');
  });
}
