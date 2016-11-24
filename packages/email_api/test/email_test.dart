// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:email_api/email_api.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';
import 'package:test/test.dart';

void main() {
  EmailAPI api;

  setUpAll(() {
    api = new EmailAPI(
      id: '732972632604-ld034vagbi5atm8s36f33o67s1giibom.apps.googleusercontent.com',
      secret: 'zufYdWLmKE4HeumTsvsmHL7_',
      token:
          'ya29.Ci-fA98ky5Pk9YDhgU4kpGAy15ZDH2gNrEK59cQ8xpfCTFuDeNZLi-e87B1e-5LDTw',
      expiry: DateTime.parse('2016-11-24 01:59:22.643892Z'),
      refreshToken: '1/k9TaI7IaVexqDyiTVxXQBY-WSfxvs38lA4iPfdhcLBE',
      scopes: <String>[
        'https://www.googleapis.com/auth/gmail.modify',
      ],
    );
  });

  test('api = await EmailAPI.fromConfig(...)', () async {
    EmailAPI api = await EmailAPI.fromConfig('assets/config.json');
    expect(api, isNotNull);
  }, skip: 'No config in tests.');

  test('api.labels()', () async {
    List<Label> labels = await api.labels();
    labels.forEach((Label label) {
      print('===> Label');
      print('= * id: ${label.id}');
      print('= * name: ${label.name}');
      print('= * unread: ${label.unread}');
      print('= * type: ${label.type}');
      print('');
    });
  }, skip: 'takes 4s');

  test('api.me()', () async {
    User user = await api.me();

    print('===> User');
    print('= * name: ${user.name}');
    print('= * email: ${user.email}');
    print('= * picture: ${user.picture}');
    print('');
  }, skip: 'takes 1s');

  test('api.threads()', () async {
    List<Thread> threads =
        await api.threads(labels: <String>['INBOX'], max: 15);
    threads.forEach((Thread thread) {
      print('===> Thread: $thread');
      print('= * id: ${thread.id}');
      print('= * snippet: ${thread.snippet}');
      print('= * historyId: ${thread.historyId}');
      print('= * messages: ');

      thread.messages.forEach((Message message) {
        print('=     Message: $message');
        print('=     * id: ${message.id}');
        print('=     * timestamp: ${message.timestamp}');
        print('=     * isRead: ${message.isRead}');
        print('=     * subject: ${message.subject}');
        print('=     * sender: ${message.sender}');
        print('=     * text: ${message.text}');
        print('=     * links:');
        message.links.forEach((Uri link) {
          print('=       * link: $link');
        });
        print('=     * attachments:');
        message.attachments.forEach((Attachment attachment) {
          print('=       * attachment.id: ${attachment.id}');
          print('=       * attachment.value: ${attachment.value}');
        });
        print('=');
      });

      print('');
    });
  }, skip: 'takes 4s');
}
