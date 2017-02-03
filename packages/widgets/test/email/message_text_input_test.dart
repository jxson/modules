// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgets/email.dart';

void main() {
  testWidgets(
      'Editing text in the message text input will call the onTextChange '
      'callback the entered text', (WidgetTester tester) async {
    String enteredText = 'Fuchsia is the new Black';
    String messageText;

    await tester.pumpWidget(new Material(
      child: new MessageTextInput(
        onTextChange: (String text) {
          messageText = text;
        },
      ),
    ));
    await tester.enterText(find.byType(EditableText), enteredText);
    await tester.idle();
    expect(enteredText, messageText);
  });

  testWidgets('TextInput should be pre-populated with initialText',
      (WidgetTester tester) async {
    String initialText = 'Fuchsia is the new Black';

    await tester.pumpWidget(new Material(
      child: new MessageTextInput(
        initialText: initialText,
      ),
    ));
    await tester.idle();
    EditableText editableText = tester.widget(find.byType(EditableText));
    expect(editableText.value.text, initialText);
  });

  testWidgets('Input text should use style specified in inputStyle',
      (WidgetTester tester) async {
    TextStyle style = new TextStyle(
      color: Colors.pink[500],
      fontSize: 30.0,
    );

    await tester.pumpWidget(new Material(
      child: new MessageTextInput(
        inputStyle: style,
      ),
    ));
    await tester.idle();
    EditableText editableText = tester.widget(find.byType(EditableText));
    expect(editableText.style, style);
  });

  testWidgets('Label text should use style specified in inputStyle',
      (WidgetTester tester) async {
    TextStyle style = new TextStyle(
      color: Colors.pink[500],
      fontSize: 30.0,
    );

    await tester.pumpWidget(new Material(
      child: new MessageTextInput(
        labelStyle: style,
      ),
    ));
    await tester.idle();
    Text labelText = tester.widget(find.text('Compose email'));
    expect(labelText.style, style);
  });
}
