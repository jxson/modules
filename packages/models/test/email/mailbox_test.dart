// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:models/email.dart';
import 'package:test/test.dart';

void main() {
  test('fromString() should correctly parse the string into a Mailbox', () {
    List<String> rawStrings = <String>[
      'John Doe <john.doe@example.com>',
      '  John Doe   <john.doe@example.com>   ',
      '"John Doe" <john.doe@example.com>',
      'john.doe@example.com',
      '<john.doe@example.com>',
    ];

    List<Mailbox> expected = <Mailbox>[
      new Mailbox(displayName: 'John Doe', address: 'john.doe@example.com'),
      new Mailbox(displayName: 'John Doe', address: 'john.doe@example.com'),
      new Mailbox(displayName: 'John Doe', address: 'john.doe@example.com'),
      new Mailbox(address: 'john.doe@example.com'),
      new Mailbox(address: 'john.doe@example.com'),
    ];

    for (int i = 0; i < rawStrings.length; ++i) {
      expect(
        new Mailbox.fromString(rawStrings[i]),
        equals(expected[i]),
        reason: 'The resulting Mailbox for rawString[$i] did not match the '
            'expected value.',
      );
    }
  });

  test('toString() should show: displayName <address>', () {
    Mailbox mailbox = new Mailbox(
      displayName: 'Coco',
      address: 'coco@cu.te',
    );
    expect(mailbox.toString(), 'Coco <coco@cu.te>');
  });

  test('displayText should show displayName if it is present', () {
    Mailbox mailbox = new Mailbox(
      displayName: 'Coco',
      address: 'coco@cu.te',
    );
    expect(mailbox.displayText, 'Coco');
  });

  test('displayText should show address if displayName is not present', () {
    Mailbox mailbox = new Mailbox(
      address: 'coco@cu.te',
    );
    expect(mailbox.displayText, 'coco@cu.te');
  });

  test(
      'Equality should be true if Mailbox objects have the same address '
      'and displayName', () {
    Mailbox mailbox1 = new Mailbox(
      displayName: 'Coco',
      address: 'coco@cu.te',
    );
    Mailbox mailbox2 = new Mailbox(
      displayName: 'Coco',
      address: 'coco@cu.te',
    );
    expect(mailbox1 == mailbox2, true);
  });

  test(
      'Equality should be false if Mailbox objects have different address '
      'or displayName', () {
    Mailbox mailbox1 = new Mailbox(
      displayName: 'Yoyo',
      address: 'coco@cu.te',
    );
    Mailbox mailbox2 = new Mailbox(
      displayName: 'Coco',
      address: 'coco@cu.te',
    );
    expect(mailbox1 == mailbox2, false);
  });
}
