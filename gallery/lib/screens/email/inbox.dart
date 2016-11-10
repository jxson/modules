// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:flux/email.dart';
import 'package:models/email.dart';
import 'package:widgets/email.dart';

/// An email inbox screen that shows a list of email threads, built with the
/// flux pattern.
class EmailInboxScreen extends StoreWatcher {
  /// Create a new [EmailInboxScreen] instance.
  EmailInboxScreen({
    Key key,
    this.singleLine: false,
    this.onThreadSelect,
  })
      : super(key: key);

  /// Indicates whether single line style should be used for thread list items
  final bool singleLine;

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

    return singleLine
        ? new ThreadListItemSingleLine(
            key: key,
            thread: thread,
            onSelect: handleSelect,
          )
        : new ThreadListItem(
            key: key,
            thread: thread,
            onSelect: handleSelect,
          );
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

    return new Block(children: threadListItems);
  }
}
