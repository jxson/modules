// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper Functions for Testing

/// Simulates a swipe on the given direction for a Dismissable Widget
///
/// Returns true if the direction (has to be 'startToEnd' or 'endToStart') is
/// valid and once the full sequence of animations is completed.
Future<bool> swipeDissmissable(
    {WidgetTester tester, Key key, DismissDirection direction}) async {
  switch (direction) {
    case DismissDirection.startToEnd:
      await tester.fling(find.byKey(key), new Offset(400.0, 0.0), 20.0);
      break;
    case DismissDirection.endToStart:
      await tester.fling(find.byKey(key), new Offset(-400.0, 0.0), 20.0);
      break;
    default:
      return false;
  }

  // Need to pump the widget for all the animations in a Dismissable swipe
  // Copied from flutter/packages/flutter/test/widget/dismissable_test.dart
  await tester.pump(); // start the slide
  await tester.pump(
      const Duration(seconds: 1)); // finish the slide and start shrinking...
  await tester.pump(); // first frame of shrinking animation
  await tester.pump(const Duration(
      seconds: 1)); // finish the shrinking and call the callback...
  await tester.pump(); // rebuild after the callback removes the entry

  return true;
}
