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

final Color _kSelectedBgColor = Colors.blue[200].withOpacity(0.2);

/// [ThreadListItem] is a [StatelessWidget]
///
/// An item that represents a single thread in inbox view
class ThreadListItem extends StatelessWidget {
  /// The [Thread] that this List Item should render
  final Thread thread;

  /// Callback if item is selected
  final ThreadActionCallback onSelect;

  /// Callback if item is archived
  final ThreadActionCallback onArchive;

  /// Size of avatar in List item
  final double avatarSize;

  /// Flag for when this ThreadList is "selected"
  final bool isSelected;

  /// Creates a Thread ListItem
  ///
  /// Requires a [Thread] to render
  ThreadListItem({
    Key key,
    @required this.thread,
    this.onSelect,
    this.onArchive,
    this.isSelected: false,
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
    // TODO(dayang) Save font styles in theme and retrieve from theme
    final Message lastMessage = thread.messages.last;

    final Widget avatar = new Container(
      child: new Alphatar.fromNameAndUrl(
        name: lastMessage.sender.displayText,
        avatarUrl: lastMessage.senderProfileUrl,
      ),
    );

    final Widget threadTitle = new Row(
      children: <Widget>[
        new Expanded(
          flex: 1,
          child: new ThreadParticipantList(
            thread: thread,
            isTitle: true,
          ),
        ),
        new Expanded(
          flex: null,
          child: new Container(
            padding: const EdgeInsets.only(left: 8.0),
            child: new Text(
              lastMessage.getDisplayDate(),
              style: new TextStyle(
                fontSize: 12.0,
                color: Colors.grey[500],
              ),
            ),
          ),
        ),
      ],
    );

    final Widget threadSubtitle = new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Text(
          thread.getSubject(),
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: new TextStyle(
            fontSize: 14.0,
            color: lastMessage.isRead ? Colors.grey[500] : Colors.black,
            height: 1.4,
            fontWeight:
                lastMessage.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        new Text(
          lastMessage.generateSnippet(),
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: new TextStyle(
            fontSize: 14.0,
            color: Colors.grey[500],
            height: 1.4,
          ),
        ),
      ],
    );

    final Widget listItem = new Material(
      color: isSelected ? _kSelectedBgColor : Colors.white,
      child: new ListItem(
        enabled: true,
        onTap: _handleSelect,
        isThreeLine: true,
        leading: avatar,
        title: threadTitle,
        subtitle: threadSubtitle,
      ),
    );

    //Wrap list item in Dissmissable if onArchive callback is given
    if (onArchive != null) {
      return new Dismissable(
        key: new Key('${key.toString()}-dismissable'),
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
