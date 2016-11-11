// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';

import '../user/alphatar.dart';
import 'archive_dismissable_background.dart';
import 'thread_participant_list.dart';
import 'type_defs.dart';

/// [ThreadListItemSingleLine] is a [StatelessWidget]
///
/// An item that represents a single thread in inbox view in a single-line
/// representation
class ThreadListItemSingleLine extends StatelessWidget {
  /// The [Thread] that this List Item should render
  final Thread thread;

  /// Callback if item is selected
  final ThreadActionCallback onSelect;

  /// Callback if item is archived
  final ThreadActionCallback onArchive;

  /// Size of avatar in List item
  final double avatarSize;

  /// Creates a Single Line Thread List Item
  ///
  /// Requires a [Thread] to render
  ThreadListItemSingleLine({
    Key key,
    @required this.thread,
    this.onSelect,
    this.onArchive,
    this.avatarSize: 40.0,
  })
      : super(key: key) {
    assert(thread != null);
  }

  void _handleSelect() {
    if (onSelect != null) {
      onSelect(thread);
    }
  }

  void _handleDismissed(DismissDirection direction) {
    onArchive(thread);
  }

  @override
  Widget build(BuildContext context) {
    final Message lastMessage = thread.messages.last;

    final Widget avatar = new Container(
      child: new Alphatar.withUrl(
        avatarUrl: lastMessage.senderProfileUrl,
        letter: lastMessage.sender.displayText[0],
      ),
    );

    final Widget participantList = new Container(
      padding: const EdgeInsets.only(right: 8.0),
      child: new ThreadParticipantList(thread: thread),
    );

    final Widget previewText = new RichText(
      text: new TextSpan(
        style: new TextStyle(
          fontSize: 14.0,
          height: 1.4,
        ),
        children: <TextSpan>[
          new TextSpan(
            //Message Subject
            text: thread.getSubject(),
            style: new TextStyle(
              color: Colors.black,
              fontWeight:
                  lastMessage.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          new TextSpan(
            //Message snippet
            text: ' - ${lastMessage.generateSnippet()}',
            style: new TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    );

    final Widget timestamp = new Container(
      padding: const EdgeInsets.only(left: 32.0),
      child: new Text(
        lastMessage.getDisplayDate(),
        style: new TextStyle(
          fontSize: 12.0,
          color: Colors.grey[500],
        ),
      ),
    );

    final Widget threadTitle = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Flexible(flex: 2, child: participantList),
        new Flexible(
          flex: 3,
          child: previewText,
        ),
        new Flexible(flex: null, child: timestamp),
      ],
    );

    final Widget listItem = new Material(
      color: Colors.white,
      child: new ListItem(
        enabled: true,
        onTap: _handleSelect,
        isThreeLine: false,
        leading: avatar,
        title: threadTitle,
      ),
    );

    //Wrap list item in Dissmissable if onArchive callback is given
    if (onArchive != null) {
      return new Dismissable(
        key: new UniqueKey(),
        direction: DismissDirection.horizontal,
        onDismissed: _handleDismissed,
        child: listItem,
        background: new ArchiveDismissableBackground(
          direction: DismissDirection.startToEnd,
        ),
        secondaryBackground: new ArchiveDismissableBackground(
          direction: DismissDirection.endToStart,
        ),
      );
    } else {
      return listItem;
    }
  }
}
