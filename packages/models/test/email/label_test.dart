// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:fixtures/fixtures.dart';
import 'package:models/email.dart';
import 'package:test/test.dart';

void main() {
  Fixtures fixtures = new Fixtures();

  test('Label JSON encode/decode', () {
    Label label = fixtures.label();

    String encoded = JSON.encode(label);
    Map<String, dynamic> json = JSON.decode(encoded);
    Label hydrated = new Label.fromJson(json);

    expect(hydrated.id, equals(label.id));
    expect(hydrated.name, equals(label.name));
    expect(hydrated.unread, equals(label.unread));
    expect(hydrated.type, equals(label.type));
  });
}
