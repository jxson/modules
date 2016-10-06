// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgets/user/alphatar.dart';

void main() {
  String profileUrl =
      'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg';

  testWidgets(
      'Alphatar should display the image when given, whether or not the'
      'fall-back letter is given, but also display fallback letter in'
      'the background', (WidgetTester tester) async {
    // First, try without providing a letter.
    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new Alphatar.withUrl(avatarUrl: profileUrl),
      );
    }));

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);

    // Try again with a letter provided.
    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new Alphatar.withUrl(avatarUrl: profileUrl, letter: 'L'),
      );
    }));

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets(
      'Alphatar should display the fall-back letter, '
      'when the image is not provided', (WidgetTester tester) async {
    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new Alphatar(letter: 'L'),
      );
    }));

    expect(find.byType(Image), findsNothing);
    expect(find.text('L'), findsOneWidget);
  });
}
