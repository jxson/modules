// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/email/folder.dart';
import 'package:models/email/folder_group.dart';
import 'package:widgets/email/folder_group_list.dart';

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

    int taps = 0;

    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new Material(
        child: new FolderGroupList(
          folderGroups: <FolderGroup>[folderGroup1, folderGroup2],
          onSelectFolder: (Folder f) {
            expect(f, folderGroup2.folders[0]);
            taps++;
          },
        ),
      );
    }));

    expect(taps, 0);
    await tester.tap(find.text('Advertisements'));
    expect(taps, 1);
  });
}
