// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:convert';

import 'package:models/email.dart';
import 'package:models/fixtures.dart';
import 'package:models/user.dart';
import 'package:test/test.dart';

void main() {
  ModelFixtures fixtures = new ModelFixtures();

  group('thread.getSubject()', () {
    User sender = fixtures.user(name: 'Coco Yang');
    List<User> to = <User>[fixtures.user(name: 'David Yang')];

    test('populated message subject', () {
      Thread thread = fixtures.thread(<Message>[
        fixtures.message(
            sender: sender,
            to: to,
            subject: 'Feed Me!!!',
            text: 'Woof Woof. I\'m so hungry. You need to feed me!'),
        fixtures.message(
            sender: sender,
            to: to,
            subject: 'PLEAZE Feed Me!!!',
            text: 'Woof Woof. I\'m so hungry. You need to feed me!'),
      ]);

      expect(thread.getSubject(), 'Feed Me!!!');
    });

    test('null message subject', () {
      Thread thread = fixtures.thread(<Message>[
        fixtures.message(
            sender: sender,
            to: to,
            subject: null,
            text: 'Woof Woof. I\'m so hungry. You need to feed me!'),
      ]);

      expect(thread.getSubject(), '(No Subject)');
    });

    test('empty message subject', () {
      Thread thread = fixtures.thread(<Message>[
        fixtures.message(
            sender: sender,
            to: to,
            subject: '',
            text: 'Woof Woof. I\'m so hungry. You need to feed me!'),
      ]);

      expect(thread.getSubject(), '(No Subject)');
    });
  });

  group('JSON encode/decode', () {
    ModelFixtures fixtures = new ModelFixtures();

    test('message with attachments', () {
      int ms = new DateTime.now().millisecondsSinceEpoch;
      DateTime timestamp = new DateTime.fromMillisecondsSinceEpoch(ms);
      User coco = fixtures.user(name: 'Coco Yang');
      User david = fixtures.user(name: 'David Yang');
      User jason = fixtures.user(name: 'Jason C');
      Thread thread = fixtures.thread(<Message>[
        fixtures.message(
          sender: coco,
          to: <User>[david],
          cc: <User>[jason],
          text: "Woof Woof. I'm so hungry. You need to feed me!",
          timestamp: timestamp,
          isRead: true,
          attachments: <Attachment>[
            fixtures.attachment(
              type: AttachmentType.youtubeVideo,
            ),
          ],
        ),
      ]);

      String payload = JSON.encode(thread);
      Map<String, dynamic> json = JSON.decode(payload);
      Thread hydrated = new Thread.fromJson(json);

      expect(hydrated.id, equals(thread.id));
      expect(hydrated.snippet, equals(thread.snippet));
      expect(hydrated.historyId, equals(thread.historyId));

      Message message = hydrated.messages[0];
      expect(message, isNotNull);
      expect(message.sender.displayName, equals(coco.name));
      expect(message.sender.address, equals(coco.email));
      expect(message.text,
          equals("Woof Woof. I'm so hungry. You need to feed me!"));
      expect(message.timestamp, equals(timestamp));
      expect(message.isRead, isTrue);

      Attachment attachment = message.attachments[0];
      expect(attachment, isNotNull);
      expect(attachment.type, equals(AttachmentType.youtubeVideo));

      Mailbox to = message.recipientList[0];
      expect(to, isNotNull);
      expect(to.displayName, equals(david.name));
      expect(to.address, equals(david.email));

      Mailbox cc = message.ccList[0];
      expect(cc, isNotNull);
      expect(cc.displayName, equals(jason.name));
      expect(cc.address, equals(jason.email));
    });
  });
}
