// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:models/email/message.dart';
import 'package:widgets/email/editor_action_bar_header.dart';

/// This screen displays an Google Inbox style email editor.
class EmailEditorScreen extends StatefulWidget {
  /// Creates a [EmailEditorScreen] instance.
  EmailEditorScreen({Key key}) : super(key: key);

  @override
  _EmailEditorScreenState createState() => new _EmailEditorScreenState();
}

class _EmailEditorScreenState extends State<EmailEditorScreen> {
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Message message = new Message(text: 'New Message');
    return new Scaffold(
      key: _key,
      appBar: new AppBar(
        title: new Text('Email - Editor'),
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            new EditorActionBarHeader(
              message: message,
              enableSend: true,
              onSend: _onPerformMessageAction,
              onClose: _onPerformMessageAction,
              onAttach: _onPerformMessageAction,
            ),
          ],
        ),
      ),
    );
  }

  void _onPerformMessageAction(Message message) {
    print('Action Performed');
  }
}
