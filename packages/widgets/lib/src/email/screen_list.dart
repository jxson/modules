// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:email_session_store/email_session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:models/email.dart';
import 'package:widgets/email.dart';

/// Various styles of inboxes
enum InboxStyle {
  /// Threads are represented as multi-line items
  multiLine,

  /// Threads are represeted as single-line items
  singleLine,

  /// Thread are represented as cards in a grid view
  gridView,
}

// Inbox header height needs to line up with the ThreadView header
const double _kInboxHeaderHeight = 73.0;

/// An email inbox screen that shows a list of email threads, built with the
/// flux pattern.
class EmailListScreen extends StoreWatcher {
  /// Create a new [EmailListScreen] instance.
  EmailListScreen({
    Key key,
    this.style: InboxStyle.multiLine,
    this.inboxTitle: 'Inbox',
  })
      : super(key: key) {
    assert(style != null);
    assert(inboxTitle != null);
  }

  /// Indicates whether single line style should be used for thread list items
  final InboxStyle style;

  /// Header Title for this view
  final String inboxTitle;

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(kEmailSessionStoreToken);
  }

  Widget _createThreadListItem(
      BuildContext context, Thread thread, bool focused) {
    Key key = new ObjectKey(thread);

    Widget item;
    // TODO(SO-132): Implement using multiple widgets to allow multiple modules.
    switch (style) {
      case InboxStyle.multiLine:
        item = new ThreadListItem(
          key: key,
          thread: thread,
          onSelect: emailSessionFocusThread.call,
          isSelected: focused,
        );
        break;
      case InboxStyle.singleLine:
        item = new ThreadListItemSingleLine(
          key: key,
          thread: thread,
          onSelect: emailSessionFocusThread.call,
        );
        break;
      case InboxStyle.gridView:
        item = new ThreadGridItem(
          key: key,
          thread: thread,
          onSelect: emailSessionFocusThread.call,
        );
        break;
      default:
        throw new Exception('Invalid Inbox style.');
    }

    return item;
  }

  @override
  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    final EmailSessionStore emailSession = stores[kEmailSessionStoreToken];

    if (emailSession.fetchingThreads) {
      return new Center(child: new CircularProgressIndicator());
    }

    if (emailSession.currentErrors.isNotEmpty) {
      // TODO(alangardner): Grab more than just the first error.
      Error error = emailSession.currentErrors[0];
      return new Text('Error occurred while retrieving email threads: '
          '$error');
    }

    String focusedThreadId = emailSession.focusedThread?.id;
    List<Widget> threadListItems = <Widget>[];
    emailSession.visibleThreads.forEach((Thread t) {
      threadListItems
          .add(_createThreadListItem(context, t, t.id == focusedThreadId));
    });

    // Use a standard Block to vertically place threadItems in the singleLine
    // and multiLine inbox styles. Use a ThreadGridLayout to place threadItems
    // for the gridView style inbox.
    Widget threadList;
    if (style == InboxStyle.gridView) {
      threadList = new ThreadGridLayout(
        children: threadListItems,
      );
    } else {
      threadList = new Block(children: threadListItems);
    }

    // TODO(dayang): Use theme data
    // https://fuchsia.atlassian.net/browse/SO-43
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Container(
          height: _kInboxHeaderHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: new BoxDecoration(
            border: new Border(
              bottom: new BorderSide(
                color: Colors.grey[200],
                width: 1.0,
              ),
            ),
          ),
          child: new Row(
            children: <Widget>[
              new Text(
                inboxTitle,
                overflow: TextOverflow.ellipsis,
                style: new TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ),
        new Flexible(
          flex: 1,
          child: threadList,
        ),
      ],
    );
  }
}
