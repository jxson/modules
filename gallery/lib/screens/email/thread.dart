// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:widgets/email/thread_view.dart';
import 'package:widgets/email/message_action_bar_footer.dart';
import 'package:widgets/email/thread_action_bar_header.dart';
import 'package:models/email/message.dart';
import 'package:models/email/mock_thread.dart';
import 'package:models/email/thread.dart';

/// This screen displays an a single email thread.
class EmailThreadScreen extends StatefulWidget {
  /// Creates a [EmailThreadScreen] instance.
  EmailThreadScreen({Key key}) : super(key: key);

  @override
  _EmailThreadScreenState createState() => new _EmailThreadScreenState();
}

class _EmailThreadScreenState extends State<EmailThreadScreen> {
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  Thread _mockThread;
  Set<String> _expandedMessages;

  @override
  void initState() {
    super.initState();
    _mockThread = new MockThread();
    _expandedMessages =
        new Set<String>.from(<String>[_mockThread.messages[0].id]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _key,
      appBar: new AppBar(
        title: new Text('Email - Thread'),
      ),
      body: new ThreadView(
        thread: _mockThread,
        expandedMessageIds: _expandedMessages,
        onSelectMessage: _onSelectMessage,
        footer: new MessageActionBarFooter(
          message: _mockThread.messages.last,
          onForwardMessage: _onPerformMessageAction,
          onReplyAllMessage: _onPerformMessageAction,
          onReplyMessage: _onPerformMessageAction,
        ),
        header: new ThreadActionBarHeader(
          thread: _mockThread,
          onArchive: _onPerformThreadAction,
          onClose: _onPerformThreadAction,
          onMoreActions: _onPerformThreadAction,
          onDelete: _onPerformThreadAction,
        ),
      ),
    );
  }

  void _onSelectMessage(Message message) {
    setState(() {
      if (_expandedMessages.contains(message.id)) {
        _expandedMessages.remove(message.id);
      } else {
        _expandedMessages.add(message.id);
      }
    });
  }

  void _onPerformMessageAction(Message message) {
    print('Action Performed');
  }

  void _onPerformThreadAction(Thread thread) {
    print('Action Performed');
  }
}
