// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:widgets/email/thread_list_item.dart';
import 'package:widgets/email/thread_list_item_single_line.dart';
import 'package:models/email/mock_thread.dart';
import 'package:models/email/thread.dart';

/// This screen displays an inbox.
class EmailInboxScreen extends StatefulWidget {
  /// Creates a [EmailInboxScreen] instance.
  EmailInboxScreen({Key key}) : super(key: key);

  @override
  _EmailInboxScreenState createState() => new _EmailInboxScreenState();
}

class _EmailInboxScreenState extends State<EmailInboxScreen> {
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Thread mockThread1 = new MockThread();
    Thread mockThread2 = new MockThread();
    return new Scaffold(
      key: _key,
      appBar: new AppBar(
        title: new Text('Email - Inbox'),
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            new ThreadListItem(
              key: new ObjectKey(mockThread1),
              thread: mockThread1,
              onArchive: (Thread thread) {
                print('ARCHIVE!');
              },
            ),
            new ThreadListItemSingleLine(
              key: new ObjectKey(mockThread2),
              thread: mockThread2,
              onArchive: (Thread thread) {
                print('ARCHIVE!');
              },
            ),
          ],
        ),
      ),
    );
  }
}
