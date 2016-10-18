// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/email.dart';
import 'package:widgets/email.dart';

void main() {
  testWidgets(
      'Test to see if tapping on a FallbackAttachmentPreview will call the'
      'appropiate callback with given Attachment', (WidgetTester tester) async {
    Key attachmentKey = new UniqueKey();
    Attachment attachment = new Attachment(
      id: '1',
      content: 'WhatTheFuchsia?',
      mime: '',
    );

    int taps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new FallbackAttachmentPreview(
          key: attachmentKey,
          attachment: attachment,
          onSelect: (Attachment a) {
            expect(a, attachment);
            taps++;
          },
        ),
      );
    }));

    expect(taps, 0);
    await tester.tap(find.byKey(attachmentKey));
    expect(taps, 1);
  });
}
