// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:models/email.dart';
import 'package:test/test.dart';

void main() {
  test('Label JSON encode/decode', () {
    Label label = new Label(
      id: 'INBOX',
      name: 'Inbox',
      unread: 867,
      type: 'system',
    );

    String encoded = JSON.encode(label);
    Map<String, dynamic> json = JSON.decode(encoded);
    Label hydrated = new Label.fromJson(json);

    expect(hydrated.id, equals(label.id));
    expect(hydrated.name, equals(label.name));
    expect(hydrated.unread, equals(label.unread));
    expect(hydrated.type, equals(label.type));
  });
}
