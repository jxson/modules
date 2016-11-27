// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:convert';
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

  test('thread.toJson()', () {
    int ms = new DateTime.now().millisecondsSinceEpoch;
    DateTime timestamp = new DateTime.fromMillisecondsSinceEpoch(ms);
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
            ccList: <Mailbox>[
              new Mailbox(
                address: 'jason@example.org',
                displayName: 'Jason',
              )
            ],
            subject: null,
            text: "Woof Woof. I'm so hungry. You need to feed me!",
            timestamp: timestamp,
            isRead: true,
            attachments: <Attachment>[
              new Attachment(
                id: 'foo',
                value: 'bar',
                type: AttachmentType.youtubeVideo,
              )
            ]),
      ],
    );

    String payload = JSON.encode(thread);
    Map<String, dynamic> json = JSON.decode(payload);
    Thread hydrated = new Thread.fromJson(json);

    expect(hydrated.id, equals(thread.id));
    expect(hydrated.snippet, equals(thread.snippet));
    expect(hydrated.historyId, equals(thread.historyId));

    Message message = hydrated.messages[0];
    expect(message, isNotNull);
    expect(message.sender.displayName, equals('Coco Yang'));
    expect(message.sender.address, equals('cocoyang@cu.te'));
    expect(message.text,
        equals("Woof Woof. I'm so hungry. You need to feed me!"));
    expect(message.timestamp, equals(timestamp));
    expect(message.isRead, isTrue);

    Attachment attachment = message.attachments[0];
    expect(attachment, isNotNull);
    expect(attachment.type, equals(AttachmentType.youtubeVideo));

    Mailbox to = message.recipientList[0];
    expect(to, isNotNull);
    expect(to.displayName, equals('David Yang'));
    expect(to.address, equals('david@ya.ng'));

    Mailbox cc = message.ccList[0];
    expect(cc, isNotNull);
    expect(cc.displayName, equals('Jason'));
    expect(cc.address, equals('jason@example.org'));
  });
}
