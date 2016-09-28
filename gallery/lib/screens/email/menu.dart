// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:widgets/email/folder_list_item.dart';
import 'package:models/email/folder.dart';

/// This screen displays an inbox.
class EmailMenuScreen extends StatefulWidget {
  /// Creates a [EmailMenuScreen] instance.
  EmailMenuScreen({Key key}) : super(key: key);

  @override
  _EmailMenuScreenState createState() => new _EmailMenuScreenState();
}

class _EmailMenuScreenState extends State<EmailMenuScreen> {
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Folder mockFolder1 = new Folder(
      id: 'INBOX',
      name: 'Inbox',
      unread: 2,
      type: 'system',
    );
    Folder mockFolder2 = new Folder(
      id: 'STARRED',
      name: 'Starred',
      unread: 0,
      type: 'system',
    );
    return new Scaffold(
      key: _key,
      appBar: new AppBar(
        title: new Text('Email - Menu'),
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            new FolderListItem(
              folder: mockFolder1,
              selected: true,
              icon: Icons.inbox,
            ),
            new FolderListItem(
              folder: mockFolder2,
              icon: Icons.star,
            ),
          ],
        ),
      ),
    );
  }
}
