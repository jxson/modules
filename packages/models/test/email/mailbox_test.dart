// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:models/email/mailbox.dart';
import 'package:test/test.dart';

void main() {
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
