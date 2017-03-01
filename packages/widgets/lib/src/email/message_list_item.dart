// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';

import '../user/alphatar.dart';
import 'message_content.dart';
import 'type_defs.dart';

const Duration _kExpandAnimationDuration = const Duration(milliseconds: 200);

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

  /// Callback for selecting forward in popup action menu
  MessageActionCallback onForward;

  /// Callback for selecting reply all in popup action menu
  MessageActionCallback onReplyAll;

  /// Callback for selecting reply in popup action menu
  MessageActionCallback onReply;

  /// Creates new MessageListItem
  MessageListItem({
    Key key,
    @required this.message,
    @required this.onForward,
    @required this.onReplyAll,
    @required this.onReply,
    this.onHeaderTap,
    this.isExpanded: false,
  })
      : super(key: key) {
    assert(message != null);
  }

  /// Creates main title
  /// Show timestamp if message is expanded
  Widget _buildMessageTitle() {
    final Widget titleText = new Text(
      message.sender.displayText,
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
          new Expanded(
            flex: 1,
            child: titleText,
          ),
          new Text(
            message.displayDate,
            style: new TextStyle(
              fontSize: 12.0,
              color: Colors.grey[500],
            ),
          ),
          new PopupMenuButton<MessageActionCallback>(
            child: new Icon(
              Icons.more_vert,
              color: Colors.grey[500],
              size: 20.0,
            ),
            itemBuilder: (BuildContext context) =>
                <PopupMenuItem<MessageActionCallback>>[
                  new PopupMenuItem<MessageActionCallback>(
                    value: onReply,
                    child: new ListItem(
                      leading: new Icon(Icons.reply),
                      title: new Text('Reply'),
                    ),
                  ),
                  new PopupMenuItem<MessageActionCallback>(
                    value: onReplyAll,
                    child: new ListItem(
                      leading: new Icon(Icons.reply_all),
                      title: new Text('Reply All'),
                    ),
                  ),
                  new PopupMenuItem<MessageActionCallback>(
                    value: onForward,
                    child: new ListItem(
                      leading: new Icon(Icons.forward),
                      title: new Text('Forward'),
                    ),
                  ),
                ],
            onSelected: (MessageActionCallback messageCallback) {
              messageCallback(message);
            },
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
      List<String> allRecipientList = <String>[]
        ..addAll(message.recipientList.map((Mailbox m) => m.displayText))
        ..addAll(message.ccList.map((Mailbox m) => m.displayText));
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

  void _handleHeaderTap() {
    if (onHeaderTap != null) {
      onHeaderTap(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget avatar = new Alphatar.fromNameAndUrl(
      name: message.sender.displayText,
      avatarUrl: message.senderProfileUrl,
    );

    final Widget messageTitle = _buildMessageTitle();

    final Widget messageSubtitle = _buildMessageSubtitle();

    final List<Widget> childWidgets = <Widget>[
      new ListItem(
        key: new ObjectKey(message),
        enabled: true,
        onTap: _handleHeaderTap,
        isThreeLine: false,
        leading: avatar,
        title: messageTitle,
        subtitle: messageSubtitle,
      ),
      new AnimatedCrossFade(
        firstChild: new Container(),
        secondChild: new Row(
          // The AnimatedCrossFade widget is intended to animate between
          // widgets with the same widget. There will be "jitter" otherwise.
          // Wrapping the content in a row of Flex=1 will will ensure that the
          // both widgets stretch the entire space and have the smae width
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              flex: 1,
              child: new MessageContent(message: message),
            ),
          ],
        ),
        firstCurve: new Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
        secondCurve: new Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.fastOutSlowIn,
        crossFadeState:
            isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: _kExpandAnimationDuration,
      ),
    ];

    return new Material(
      color: Colors.white,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: childWidgets,
      ),
    );
  }
}
