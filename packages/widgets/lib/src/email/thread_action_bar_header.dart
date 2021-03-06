// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';

import 'type_defs.dart';

/// Google Inbox style Header for a single [Thread]
/// Contains [Thread] level actions (Archive, Delete) and thread subject
class ThreadActionBarHeader extends StatelessWidget {
  /// [Thread] that this header is rendered for
  Thread thread;

  /// Callback for archiving thread
  ThreadActionCallback onArchive;

  /// Callback for deleting thread
  ThreadActionCallback onDelete;

  /// Callback for 'more-actions/vertical-ellipsis' affordance
  ThreadActionCallback onMoreActions;

  /// Creates an action bar header for a [Thread]
  // TODO (dayang) Action callbcks should be optional and corresponding
  // action button should be not shown if a callback is not provided.
  ThreadActionBarHeader({
    Key key,
    @required this.thread,
    @required this.onArchive,
    @required this.onDelete,
    @required this.onMoreActions,
  })
      : super(key: key) {
    assert(thread != null);
    assert(onArchive != null);
    assert(onDelete != null);
    assert(onMoreActions != null);
  }

  void _handleDelete() {
    onDelete(thread);
  }

  void _handleArchive() {
    onArchive(thread);
  }

  void _handleMoreActions() {
    onMoreActions(thread);
  }

  /// Builds row of buttons for header
  Widget _buildButtonRow() {
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
              ),
            ),
          ),
        ),
        new ButtonBar(
          alignment: MainAxisAlignment.end,
          children: <Widget>[
            new IconButton(
              icon: new Icon(Icons.delete),
              onPressed: _handleDelete,
              color: Colors.grey[600],
            ),
            new IconButton(
              icon: new Icon(Icons.archive),
              onPressed: _handleArchive,
              color: Colors.grey[600],
            ),
            new IconButton(
              icon: new Icon(Icons.more_vert),
              onPressed: _handleMoreActions,
              color: Colors.grey[600],
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.white,
      child: new Container(
        child: _buildButtonRow(),
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
}
