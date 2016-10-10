// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:models/email/mailbox.dart';
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
          subject: 'Feed Me!!!',
          text: "Woof Woof. I'm so hungry. You need to feed me!",
          timestamp: new DateTime.now(),
          isRead: true,
        ),
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
          subject: 'PLEAZE Feed Me!!!',
          text: "Woof Woof. I'm so hungry. You need to feed me!",
          timestamp: new DateTime.now(),
          isRead: true,
        ),
      ],
    );
    expect(thread.getSubject(), 'Feed Me!!!');
  });

  test(
      'getSubject() should default to (No Subject) if subject is null'
      'for first message of thread', () {
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
          subject: null,
          text: "Woof Woof. I'm so hungry. You need to feed me!",
          timestamp: new DateTime.now(),
          isRead: true,
        ),
      ],
    );
    expect(thread.getSubject(), '(No Subject)');
  });

  test(
      'getSubject() should default to (No Subject) if subject is a empty string'
      'for first message of thread', () {
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
          subject: '',
          text: "Woof Woof. I'm so hungry. You need to feed me!",
          timestamp: new DateTime.now(),
          isRead: true,
        ),
      ],
    );
    expect(thread.getSubject(), '(No Subject)');
  });
}
