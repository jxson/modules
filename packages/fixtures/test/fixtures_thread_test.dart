// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fixtures/fixtures.dart';
import 'package:models/email.dart';
import 'package:test/test.dart';

void main() {
  Fixtures fixtures = new Fixtures();

  test('fixtures.thread()', () {
    Thread thread = fixtures.thread();

    expect(thread.id, isNotNull);
    expect(thread.snippet, isNotNull);
    expect(thread.historyId, isNotNull);
    expect(thread.messages, isNotEmpty);
  });
}
