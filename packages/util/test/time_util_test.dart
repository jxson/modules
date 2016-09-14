// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:util/time_util.dart';

void main() {
  test('isSameDay() should return true if two times occur in the same day', () {
    DateTime time1 = DateTime.parse('1969-07-20 20:18:00');
    DateTime time2 = DateTime.parse('1969-07-20 06:18:00');
    expect(TimeUtil.isSameDay(time1, time2), true);
  });

  test('isSameDay() should return false if two times occur in different days',
      () {
    DateTime time1 = DateTime.parse('1969-07-20 20:18:00');
    DateTime time2 = DateTime.parse('1969-07-21 06:18:00');
    expect(TimeUtil.isSameDay(time1, time2), false);
  });
}
