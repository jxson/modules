// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';

import '../user/alphatar.dart';
import 'thread_participant_list.dart';
import 'type_defs.dart';

/// UI widget that represents a single thread in a grid-tile view
class ThreadGridItem extends StatelessWidget {
  /// The [Thread] to render
  final Thread thread;

  /// Callback if item is selected
  final ThreadActionCallback onSelect;

  /// Callback for 'more-actions/vertical-ellipsis' affordance
  ThreadActionCallback onMoreActions;

  /// Size of avatar in Grid item
  final double avatarSize;

  /// Creates a Thread Grid Item
  ///
  /// Requires a [Thread] to render
  ThreadGridItem({
    Key key,
    @required this.thread,
    this.onSelect,
    this.onMoreActions,
    this.avatarSize: 40.0,
  })
      : super(key: key) {
    assert(thread != null);
  }

  void _handleMoreActions() {
    onMoreActions?.call(thread);
  }

  void _handleSelect() {
    onSelect?.call(thread);
  }

  Widget _buildHeader() {
    return new Row(
      children: <Widget>[
        new Flexible(
          flex: 1,
          child: new Container(
            constraints: new BoxConstraints(maxHeight: 86.0),
            padding: const EdgeInsets.all(16.0),
            child: new Text(
              thread.getSubject(),
              overflow: TextOverflow.ellipsis,
              style: new TextStyle(
                fontSize: 18.0,
                height: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        new IconButton(
          icon: new Icon(Icons.more_vert),
          onPressed: _handleMoreActions,
          color: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildBody() {
    final Message lastMessage = thread.messages.last;
    return new Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: new Alphatar.fromNameAndUrl(
              name: lastMessage.sender.displayText,
              avatarUrl: lastMessage.senderProfileUrl,
            ),
          ),
          new Flexible(
            flex: 1,
            child: new Container(
              padding: const EdgeInsets.only(
                right: 16.0,
                top: 10.0,
              ),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new ThreadParticipantList(thread: thread),
                  new Container(
                    margin: const EdgeInsets.only(top: 4.0),
                    child: new Text(
                      lastMessage.generateSnippet(),
                      softWrap: true,
                      style: new TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      color: Colors.white,
      child: new InkWell(
        onTap: _handleSelect,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(),
            _buildBody(),
          ],
        ),
      ),
    );
  }
}
