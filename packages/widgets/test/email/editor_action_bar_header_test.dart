// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/email.dart';
import 'package:widgets/email.dart';

void main() {
  testWidgets(
      'Test to see if tapping on the ClOSE, ATTACH, and SEND buttons'
      'will call the appropiate callbacks', (WidgetTester tester) async {
    Message message = new Message(
      text: 'New Message',
    );
    int attachTaps = 0;
    int closeTaps = 0;
    int sendTaps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new EditorActionBarHeader(
          enableSend: true,
          message: message,
          onAttach: (Message m) {
            expect(m, message);
            attachTaps++;
          },
          onClose: (Message m) {
            expect(m, message);
            closeTaps++;
          },
          onSend: (Message m) {
            expect(m, message);
            sendTaps++;
          },
        ),
      );
    }));

    expect(attachTaps, 0);
    expect(closeTaps, 0);
    expect(sendTaps, 0);
    await tester.tap(find.byWidgetPredicate(
        (Widget widget) => widget is Icon && widget.icon == Icons.attach_file));
    expect(attachTaps, 1);
    expect(closeTaps, 0);
    expect(sendTaps, 0);
    await tester.tap(find.byWidgetPredicate(
        (Widget widget) => widget is Icon && widget.icon == Icons.close));
    expect(attachTaps, 1);
    expect(closeTaps, 1);
    expect(sendTaps, 0);
    await tester.tap(find.byWidgetPredicate(
        (Widget widget) => widget is Icon && widget.icon == Icons.send));
    expect(attachTaps, 1);
    expect(closeTaps, 1);
    expect(sendTaps, 1);
  });

  testWidgets(
      'Test to see that the SEND button is disabled when enableSend is set to '
      'false', (WidgetTester tester) async {
    Message message = new Message(
      text: 'New Message',
    );
    int sendTaps = 0;
    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new EditorActionBarHeader(
          enableSend: false,
          message: message,
          onAttach: (Message m) {},
          onClose: (Message m) {},
          onSend: (Message m) {
            expect(m, message);
            sendTaps++;
          },
        ),
      );
    }));
    expect(sendTaps, 0);
    await tester.tap(find.byWidgetPredicate(
        (Widget widget) => widget is Icon && widget.icon == Icons.send));
    expect(sendTaps, 0);
  });
}
