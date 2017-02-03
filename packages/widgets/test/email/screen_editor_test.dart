// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/email.dart';
import 'package:widgets/email.dart';

void main() {
  testWidgets('Editor inputs should pre-populate with given message as draft',
      (WidgetTester tester) async {
    Message message = new Message(
      recipientList: <Mailbox>[
        new Mailbox(address: 'coco@cu.te'),
      ],
      subject: 'About Fuchsias...',
      text: 'Fuchsia is the new black',
    );

    await tester.pumpWidget(new MaterialApp(
      home: new Material(
        child: new EditorScreen(
          draft: message,
        ),
      ),
    ));
    await tester.idle();
    EditableText subjectEditableText = tester.widget(find.descendant(
      of: find.byType(SubjectInput),
      matching: find.byType(EditableText),
    ));
    expect(subjectEditableText.value.text, message.subject);
    EditableText messageEditableText = tester.widget(find.descendant(
      of: find.byType(MessageTextInput),
      matching: find.byType(EditableText),
    ));
    expect(messageEditableText.value.text, message.text);
    expect(
        find.descendant(
          of: find.byType(RecipientInput),
          matching: find.text(message.recipientList[0].address),
        ),
        findsOneWidget);
  });

  testWidgets(
      'onDraftChanged with updated message should be called when the subject is'
      'edited ', (WidgetTester tester) async {
    String messageText = 'Fuchsia is the new black';
    Message message;

    await tester.pumpWidget(new MaterialApp(
      home: new Material(
        child: new EditorScreen(
          onDraftChanged: (Message m) {
            message = m;
          },
        ),
      ),
    ));

    await tester.enterText(
        find.descendant(
          of: find.byType(MessageTextInput),
          matching: find.byType(EditableText),
        ),
        messageText);
    await tester.idle();
    expect(message.text, messageText);
  });

  testWidgets(
      'onDraftChanged with updated message should be called when the message '
      'text is edited ', (WidgetTester tester) async {
    String subject = 'About Fuchsias...';
    Message message;

    await tester.pumpWidget(new MaterialApp(
      home: new Material(
        child: new EditorScreen(
          onDraftChanged: (Message m) {
            message = m;
          },
        ),
      ),
    ));

    await tester.enterText(
        find.descendant(
          of: find.byType(SubjectInput),
          matching: find.byType(EditableText),
        ),
        subject);
    await tester.idle();
    expect(message.subject, subject);
  });

  testWidgets(
      'onDraftChanged with updated message should be called when recipient '
      'list is edited ', (WidgetTester tester) async {
    Message draft = new Message(
      recipientList: <Mailbox>[
        new Mailbox(address: 'coco@cu.te'),
      ],
    );
    Message message;
    await tester.pumpWidget(new MaterialApp(
      home: new Material(
        child: new EditorScreen(
          draft: draft,
          onDraftChanged: (Message m) {
            message = m;
          },
        ),
      ),
    ));

    await tester.tap(find.descendant(
      of: find.byType(RecipientInput),
      matching: find.byWidgetPredicate(
          (Widget widget) => widget is Icon && widget.icon == Icons.cancel),
    ));
    expect(message.recipientList.length, 0);
  });
}
