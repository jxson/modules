// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/user/user.dart';
import 'package:models/email/folder.dart';
import 'package:models/email/folder_group.dart';
import 'package:widgets/email/inbox_menu.dart';

void main() {
  testWidgets(
      'Test to see if tapping on a FolderListItem inside a FolderGroupList '
      'will call the appropiate callback', (WidgetTester tester) async {
    FolderGroup folderGroup1 = new FolderGroup(
      folders: <Folder>[
        new Folder(name: 'Primary'),
        new Folder(name: 'Archived'),
      ],
    );
    FolderGroup folderGroup2 = new FolderGroup(
      name: 'Labels',
      folders: <Folder>[
        new Folder(name: 'Advertisements'),
        new Folder(name: 'Travel'),
        new Folder(name: 'Finance'),
      ],
    );
    User user = new User(
      name: 'Coco Yang',
      email: 'littlePuppyCoco@puppy.cute',
      picture:
          'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg',
    );

    int taps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new InboxMenu(
          folderGroups: <FolderGroup>[folderGroup1, folderGroup2],
          onSelectFolder: (Folder f) {
            expect(f, folderGroup2.folders[0]);
            taps++;
          },
          user: user,
        ),
      );
    }));

    expect(taps, 0);
    await tester.tap(find.text('Advertisements'));
    expect(taps, 1);
  });
}
