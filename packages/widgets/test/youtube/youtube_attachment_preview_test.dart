// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/email.dart';
import 'package:widgets/attachment.dart';

void main() {
  testWidgets(
      'Test to see if tapping on a YoutubeAttachmentPreview will call the'
      'appropiate callback with given Attachment', (WidgetTester tester) async {
    Key attachmentKey = new UniqueKey();
    Attachment attachment = new Attachment(
      id: '1',
      content: '9DNFzHTUAM4',
      type: AttachmentType.youtube,
    );

    int taps = 0;

    // Map<Symbol, dynamic> arguments = new Map<Symbol, dynamic>();
    // arguments[const Symbol("attachment")] = attachment;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new YoutubeAttachmentPreview(
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
