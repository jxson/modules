// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:models/email/message.dart';
import 'package:test/test.dart';

void main() {
  group('Message', () {
    setUp(() {
      Attributes attributes = fixtures('message');
    });

    test('.generateSnippet() should return text of message', () {
      String messageText = 'Baku in the Bathroom';
      Message message = new Message(text: messageText);
      expect(message.generateSnippet(), messageText);
    });
  });

  test(
      'getDisplayDate() should return minutes/hour/period'
      'format if currentDate is same as message date', () {
    Message message = new Message(
      text: 'Baku in the Bathroom',
      timestamp: DateTime.parse('1969-07-20 20:18:00'),
    );
    DateTime currentDate = DateTime.parse('1969-07-20 23:18:00');
    String displayDate = message.getDisplayDate(relativeTo: currentDate);
    expect(displayDate, '8:18 PM');
  });

  test(
      'getDisplayDate() should return Month/Day'
      'format if currentDate is not same as message date', () {
    Message message = new Message(
      text: 'Baku in the Bathroom',
      timestamp: DateTime.parse('1969-07-19 20:18:00'),
    );
    DateTime currentDate = DateTime.parse('1969-07-20 23:18:00');
    String displayDate = message.getDisplayDate(relativeTo: currentDate);
    expect(displayDate, 'Jul 19');
  });
}
