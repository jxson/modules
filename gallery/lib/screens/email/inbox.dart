// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:flux/email.dart';
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

/// An email inbox screen that shows a list of email threads, built with the
/// flux pattern.
class EmailInboxScreen extends StoreWatcher {
  /// Create a new [EmailInboxScreen] instance.
  EmailInboxScreen({
    Key key,
    this.style: InboxStyle.multiLine,
    this.onThreadSelect,
  })
      : super(key: key) {
    assert(style != null);
  }

  /// Indicates whether single line style should be used for thread list items
  final InboxStyle style;

  /// Callback for the thread selection.
  ///
  /// The behavior defaults to `Navigator.pushNamed()` to the selected email
  /// thread view.
  final ThreadActionCallback onThreadSelect;

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(kEmailStoreToken);
  }

  Widget _createThreadListItem(BuildContext context, Thread thread) {
    Key key = new ObjectKey(thread);

    ThreadActionCallback handleSelect = onThreadSelect ??
        (Thread thread) {
          Navigator.pushNamed(context, '/email/thread/${thread.id}');
        };

    switch (style) {
      case InboxStyle.multiLine:
        return new ThreadListItem(
          key: key,
          thread: thread,
          onSelect: handleSelect,
        );
      case InboxStyle.singleLine:
        return new ThreadListItemSingleLine(
          key: key,
          thread: thread,
          onSelect: handleSelect,
        );
      case InboxStyle.gridView:
        return new ThreadGridItem(
          key: key,
          thread: thread,
          onSelect: handleSelect,
        );
    }
  }

  @override
  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    final EmailStore emailStore = stores[kEmailStoreToken];

    if (emailStore.fetching) {
      return new Center(child: new CircularProgressIndicator());
    }

    if (emailStore.exception != null) {
      return new Text('Error occurred while retrieving email threads: '
          '${emailStore.exception}');
    }

    List<Widget> threadListItems = <Widget>[];
    emailStore.threads.forEach((Thread t) {
      threadListItems.add(_createThreadListItem(context, t));
    });

    if (style == InboxStyle.gridView) {
      return new Block(
        children: <Widget>[
          new ThreadGridLayout(
            children: threadListItems,
          ),
        ],
      );
    }

    // Use a standard block to vertically place threadItems in the singleLine
    // and multiLine inbox styles
    return new Block(children: threadListItems);
  }
}
