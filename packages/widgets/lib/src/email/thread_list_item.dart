// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';
import 'package:resolver/resolver.dart';

import '../user/alphatar.dart';
import 'archive_dismissable_background.dart';
import 'fallback_attachment_preview.dart';
import 'thread_participant_list.dart';
import 'type_defs.dart';

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

  /// Creates a Thread ListItem
  ///
  /// Requires a [Thread] to render
  ThreadListItem(
      {Key key,
      @required this.thread,
      this.onSelect,
      this.onArchive,
      this.avatarSize: 40.0})
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
      child: new Alphatar.withUrl(
        avatarUrl: lastMessage.senderProfileUrl,
        letter: lastMessage.sender.displayText[0],
      ),
    );

    final Widget threadTitle = new Row(
      children: <Widget>[
        new Flexible(
          flex: 1,
          child: new Text(
            thread.getSubject(),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: new TextStyle(
              fontSize: 16.0,
              fontWeight:
                  lastMessage.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
        ),
        new Flexible(
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
        new ThreadParticipantList(thread: thread),
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

    final List<Widget> children = <Widget>[
      new ListItem(
        enabled: true,
        onTap: _handleSelect,
        isThreeLine: true,
        leading: avatar,
        title: threadTitle,
        subtitle: threadSubtitle,
      ),
    ];

    BoxConstraints constraints = new BoxConstraints(
      minWidth: 25.0,
      maxWidth: 100.0,
      minHeight: 50.0,
      maxHeight: 50.0,
    );
    List<ResolverCapability> capabilities = <ResolverCapability>[
      ResolverCapability.gestures,
    ];
    List<Widget> attachments = <Widget>[];
    thread.attachments.forEach((Attachment attachment) {
      Map<Symbol, dynamic> arguments = new Map<Symbol, dynamic>();
      arguments[const Symbol("attachment")] = attachment;

      attachments.add(new Container(
        margin: const EdgeInsets.only(right: 8.0),
        child: new Resolver.resolve(
          constraints: constraints,
          capabilities: capabilities,
          name: 'examples:youtube',
          arguments: arguments,
          fallback: new FallbackAttachmentPreview(
            attachment: attachment,
          )
        )
      ));
    });

    if (attachments.isNotEmpty) {
      children.add(
        new Container(
          height: 66.0,
          child: new Block(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(
              left: 72.0,
              right: 16.0,
              bottom: 16.0,
            ),
            children: attachments,
          )));
      }

    final Widget listItem = new Material(
      color: Colors.white,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
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
