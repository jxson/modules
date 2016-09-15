// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email/message.dart';

import 'alphatar.dart';
import 'message_content.dart';
import 'type_defs.dart';

/// [MessageListItem] is a [StatelessWidget]
///
/// An item that represents a single email [Message]
/// Can be expanded to show full message through the [isExpanded] parameter
class MessageListItem extends StatelessWidget {
  /// Email [Message] that this widget will render
  Message message;

  /// True if message is fully expanded to show content
  bool isExpanded;

  /// Callback if MessageListItem header is tapped
  MessageActionCallback onHeaderTap;

  /// Creates new MessageListItem
  MessageListItem(
      {Key key,
      @required this.message,
      this.onHeaderTap,
      this.isExpanded: false})
      : super(key: key) {
    assert(message != null);
  }

  /// Creates main title
  /// Show timestamp if message is expanded
  Widget _buildMessageTitle() {
    final Widget titleText = new Text(
      message.sender,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: new TextStyle(
        fontSize: 14.0,
        fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
      ),
    );

    if (isExpanded) {
      return new Row(
        children: <Widget>[
          new Flexible(
            flex: 1,
            child: titleText,
          ),
          new Flexible(
            flex: null,
            child: new Text(
              message.getDisplayDate(),
              style: new TextStyle(
                fontSize: 12.0,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      );
    } else {
      return titleText;
    }
  }

  /// Creates subtitle for message
  /// If message is expanded, the subtitle will show the recipients of the
  /// message.
  /// If message is not expanded, the subtitle will show the message snippet
  Widget _buildMessageSubtitle() {
    String subtitleText;

    if (isExpanded) {
      // Create list of both CCed and direct recipients of email
      List<String> allRecipientList =
          new List<String>.from(message.recipientList)..addAll(message.ccList);
      subtitleText = 'to ${allRecipientList.join(', ')}';
    } else {
      subtitleText = message.generateSnippet();
    }

    return new Text(
      subtitleText,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: new TextStyle(
        fontSize: 12.0,
        color: Colors.grey[500],
      ),
    );
  }

  void _onHeaderTap() {
    if (onHeaderTap != null) {
      onHeaderTap(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget avatar = new Alphatar(avatarUrl: message.senderProfileUrl);

    final Widget messageTitle = _buildMessageTitle();

    final Widget messageSubtitle = _buildMessageSubtitle();

    final List<Widget> childWidgets = <Widget>[
      new ListItem(
        key: new ObjectKey(message),
        enabled: true,
        onTap: _onHeaderTap,
        isThreeLine: false,
        leading: avatar,
        title: messageTitle,
        subtitle: messageSubtitle,
      ),
    ];

    // Add message content if the given item is expanded
    if (isExpanded) {
      childWidgets.add(new MessageContent(message: message));
    }

    return new Material(
      color: Colors.white,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: childWidgets,
      ),
    );
  }
}
