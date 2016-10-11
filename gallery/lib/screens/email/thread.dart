// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:clients/email_client.dart';
import 'package:clients/gmail_client.dart';
import 'package:flutter/material.dart';
import 'package:models/email.dart';
import 'package:widgets/email.dart';

/// This screen displays an a single email thread.
class EmailThreadScreen extends StatefulWidget {
  /// Creates a [EmailThreadScreen] instance.
  EmailThreadScreen({Key key, this.accessToken, this.threadId})
      : super(key: key);

  /// Access token for the Gmail API.
  final String accessToken;

  /// The string ID of the current thread.
  final String threadId;

  @override
  _EmailThreadScreenState createState() => new _EmailThreadScreenState();
}

class _EmailThreadScreenState extends State<EmailThreadScreen> {
  bool _inProgress = false;
  String _errorMessage;

  Thread _thread;
  Set<String> _expandedMessages;
  EmailClient _emailClient;

  @override
  void initState() {
    super.initState();

    if (config.accessToken != null) {
      _emailClient = new GmailClient(accessToken: config.accessToken);

      // Get the email threads using the email client.
      _emailClient.getThread(config.threadId).then((Thread thread) {
        if (mounted) {
          setState(() {
            _inProgress = false;
            _thread = thread;
            _initExpandedMessages();
          });
        }
      }).catchError((Exception e) {
        if (mounted) {
          setState(() {
            _inProgress = false;
            _errorMessage =
                'Error occurred while retrieving email threads:\n$e';
          });
        }
      });

      _inProgress = true;
    } else {
      _thread = new MockThread();
      _initExpandedMessages();
    }
  }

  void _initExpandedMessages() {
    // Skip expanding the first message to quickly demonstrate both the
    // collapsed message and the expanded message.
    _expandedMessages =
        new Set<String>.from(_thread.messages.skip(1).map((Message m) => m.id));
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Just show a progress bar while waiting for the email data.
    if (_inProgress) {
      return new CircularProgressIndicator();
    }

    // Show the error message, if an error occurred while retrieving email data.
    if (_errorMessage != null) {
      return new Text(_errorMessage);
    }

    return new ThreadView(
      thread: _thread,
      expandedMessageIds: _expandedMessages,
      onSelectMessage: _handleSelectMessage,
      onForwardMessage: _handleMessageAction,
      onReplyAllMessage: _handleMessageAction,
      onReplyMessage: _handleMessageAction,
      footer: new MessageActionBarFooter(
        message: _thread.messages.last,
        onForwardMessage: _handleMessageAction,
        onReplyAllMessage: _handleMessageAction,
        onReplyMessage: _handleMessageAction,
      ),
      header: new ThreadActionBarHeader(
        thread: _thread,
        onArchive: _handleThreadAction,
        onClose: _onClose,
        onMoreActions: _handleThreadAction,
        onDelete: _handleThreadAction,
      ),
    );
  }

  void _onClose(Thread thread) {
    Navigator.pop(context);
  }

  void _handleSelectMessage(Message message) {
    setState(() {
      if (_expandedMessages.contains(message.id)) {
        _expandedMessages.remove(message.id);
      } else {
        _expandedMessages.add(message.id);
      }
    });
  }

  void _handleMessageAction(Message message) {
    print('Action Performed');
  }

  void _handleThreadAction(Thread thread) {
    print('Action Performed');
  }
}
