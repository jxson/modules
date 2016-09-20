// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email/message.dart';
import 'package:models/email/thread.dart';

import 'message_list_item.dart';
import 'type_defs.dart';

/// View for a single email [Thread].
class ThreadView extends StatelessWidget {
  /// Given thread to render
  Thread thread;

  /// Set of Ids for messages that should be expanded
  Set<String> expandedMessageIds;

  /// Callback for when a given message is selected in thread
  MessageActionCallback onSelectMessage;

  /// Optional footer widget that is rendered at the bottom of the thread
  Widget footer;

  /// Optional header widget that is rendered at the top of the thread
  // TODO(dayang) make headers sticky, or perhaps make the stickness an option
  Widget header;

  /// Creates a ThreadView for given [Thread]
  ThreadView(
      {Key key,
      @required this.thread,
      this.footer,
      this.header,
      this.onSelectMessage,
      this.expandedMessageIds})
      : super(key: key) {
    assert(thread != null);
    if (expandedMessageIds == null) {
      expandedMessageIds = new Set<String>();
    }
  }

  /// Builds the [Thread] subject line that at the top of the messages
  /// The subject should be limited to a maximum of two lines of text
  Widget _buildSubjectLine() {
    return new Material(
      color: Colors.white,
      child: new Container(
        child: new Row(
          children: <Widget>[
            new Flexible(
              flex: 1,
              child: new Container(
                constraints: new BoxConstraints(maxHeight: 86.0),
                padding: const EdgeInsets.all(16.0),
                child: new Text(
                  thread.getSubject(),
                  style: new TextStyle(
                    fontSize: 18.0,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        decoration: new BoxDecoration(
          border: new Border(
            bottom: new BorderSide(
              color: Colors.grey[200],
              width: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = thread.messages.map((Message message) {
      return new Container(
        decoration: new BoxDecoration(
          border: new Border(
            bottom: new BorderSide(
              color: Colors.grey[200],
              width: 1.0,
            ),
          ),
        ),
        child: new MessageListItem(
          message: message,
          key: new ObjectKey(message),
          onHeaderTap: onSelectMessage,
          isExpanded: expandedMessageIds.contains(message.id),
        ),
      );
    }).toList();

    // Prepend Thread Subject line to beginning of list of messages
    children.insert(0, _buildSubjectLine());

    // Append footer widget to end of the list of messages if specified
    if (footer != null) {
      children.add(footer);
    }

    // Prepend header widget to begiining of list of messages if specified
    if (header != null) {
      children.insert(0, header);
    }

    // Using a LazyBlock since each EmailListItem might be a different size if
    // it is expanded.
    // Using a LazyBlockChildren delegate since the number of emails in a thread
    // should be 'relatively finite'.
    return new LazyBlock(
      delegate: new LazyBlockChildren(children: children),
    );
  }
}
