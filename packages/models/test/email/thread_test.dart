// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:models/email.dart';
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

  test(
      'getAllAttachments() should return a list of all attachments of all '
      'messsages in thread ', () {
    Attachment attachment1 = new Attachment(id: '1');
    Attachment attachment2 = new Attachment(id: '2');
    Attachment attachment3 = new Attachment(id: '1');
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
          attachments: <Attachment>[attachment1],
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
          attachments: <Attachment>[attachment2, attachment3],
        ),
      ],
    );
    Iterable<Attachment> attachments = thread.attachments;
    expect(attachments.length, 3);
    expect(attachments.contains(attachment1), true);
    expect(attachments.contains(attachment2), true);
    expect(attachments.contains(attachment3), true);
  });
}
