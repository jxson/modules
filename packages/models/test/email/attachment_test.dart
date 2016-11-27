// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:models/email.dart';
import 'package:test/test.dart';

void main() {
  test('Attachment JSON encode/decode', () {
    Attachment attachment = new Attachment(
      id: 'foo',
      value: 'bar',
      type: AttachmentType.youtubeVideo,
    );
    String encoded = JSON.encode(attachment);
    Map<String, dynamic> json = JSON.decode(encoded);
    Attachment hydrated = new Attachment.fromJson(json);

    expect(hydrated.id, equals(attachment.id));
    expect(hydrated.value, equals(attachment.value));
    expect(hydrated.type, equals(attachment.type));
  });
}
