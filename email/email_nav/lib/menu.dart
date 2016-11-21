// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';
import 'package:widgets/email.dart';

/// This screen displays an inbox.
class EmailMenuScreen extends StatefulWidget {
  /// Creates a [EmailMenuScreen] instance.
  EmailMenuScreen({Key key}) : super(key: key);

  @override
  _EmailMenuScreenState createState() => new _EmailMenuScreenState();
}

class _EmailMenuScreenState extends State<EmailMenuScreen> {
  List<FolderGroup> _folderGroups;
  Folder _selectFolder;
  User _user;

  @override
  void initState() {
    _folderGroups = <FolderGroup>[
      new FolderGroup(
        folders: <Folder>[
          new Folder(
            id: 'INBOX',
            name: 'Inbox',
            unread: 10,
            type: 'system',
          ),
          new Folder(
            id: 'STARRED',
            name: 'Starred',
            unread: 5,
            type: 'system',
          ),
          new Folder(
            id: 'DRAFT',
            name: 'Starred',
            unread: 0,
            type: 'system',
          ),
          new Folder(
            id: 'TRASH',
            name: 'Trash',
            unread: 0,
            type: 'system',
          ),
        ],
      ),
      new FolderGroup(
        name: 'Work Folders',
        folders: <Folder>[
          new Folder(
            id: 'TODO',
            name: 'Todo',
            unread: 2,
            type: 'user',
          ),
          new Folder(
            id: 'COMPLETED',
            name: 'Completed',
            unread: 2,
            type: 'user',
          ),
          new Folder(
            id: 'JIRA',
            name: 'Jira',
            unread: 0,
            type: 'user',
          ),
          new Folder(
            id: 'GERRIT',
            name: 'Gerrit',
            unread: 0,
            type: 'user',
          ),
        ],
      ),
    ];
    _user = new User(
      name: 'Coco Yang',
      email: 'littlePuppyCoco@puppy.cute',
    );
    super.initState();
  }

  void _handleSelectFolder(Folder folder) {
    setState(() {
      _selectFolder = folder;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new InboxMenu(
        folderGroups: _folderGroups,
        onSelectFolder: _handleSelectFolder,
        selectedFolder: _selectFolder,
        user: _user,
      ),
    );
  }
}
