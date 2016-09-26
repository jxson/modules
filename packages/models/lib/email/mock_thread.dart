// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'thread.dart';
import 'message.dart';

// TODO(dayang) Generate mockdata rather than hard coding it in.
final String _kCocoAvatarUrl =
    'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg';

final String _kYoyoAvatarUrl =
    'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/yoyo.jpg';

/// A mock version for [Thread].
class MockThread extends Thread {
  /// Creates a mock [Thread].
  MockThread() : super() {
    id = id ?? 'thread1';
    messages = messages ??
        <Message>[
          new Message(
            id: 'm1',
            sender: 'Coco Yang',
            recipientList: <String>['David Yang'],
            // NOTE(youngseokyoon): The profile url below is intentionally set
            // to null to show how the alphatar falls back to the user initial.
            senderProfileUrl: null,
            subject: 'Feed Me!!!',
            text: 'Woof Woof. I\'m so hungry. You need to feed me!',
            timestamp: new DateTime.now(),
            isRead: true,
          ),
          new Message(
            id: 'm2',
            sender: 'Yoyo Yang',
            recipientList: <String>['David Yang'],
            senderProfileUrl: _kYoyoAvatarUrl,
            subject: 'Feed Me!!!',
            text: 'Dude, same here. I\'m starving!',
            timestamp: new DateTime.now(),
            isRead: false,
          ),
          new Message(
            id: 'm3',
            sender: 'Coco Yang',
            recipientList: <String>['David Yang'],
            senderProfileUrl: _kCocoAvatarUrl,
            subject: 'Feed Me!!!',
            text: 'Okay David, I know you are busy...but I\'m your dog! '
                'You gotta share the grub!',
            timestamp: new DateTime.now(),
            isRead: false,
          ),
        ];
  }
}
