// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:flux/email.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';
import 'package:widgets/email.dart';

/// An email thread screen that shows all the messages in a particular email
/// [Thread], built with the flux pattern.
class EmailThreadScreen extends StoreWatcher {
  /// Creates a new [EmailThreadScreen] instance.
  EmailThreadScreen({
    Key key,
    @required this.threadId,
    this.onThreadClose,
  })
      : super(key: key) {
    assert(threadId != null);
  }

  /// The string ID of the current thread.
  final String threadId;

  /// The callback function for the thread close button.
  ///
  /// If not provided, the behavior defaults to `Navigator.pop(context)`.
  final ThreadActionCallback onThreadClose;

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(kEmailStoreToken);
  }

  @override
  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    final EmailStore emailStore = stores[kEmailStoreToken];

    return new Center(child: _buildBody(context, emailStore));
  }

  Widget _buildBody(BuildContext context, EmailStore emailStore) {
    if (emailStore.fetching) {
      return new CircularProgressIndicator();
    }

    if (emailStore.exception != null) {
      return new Text('Error occurred while retrieving email threads: '
          '${emailStore.exception}');
    }

    Thread thread = emailStore.getThreadById(threadId);
    if (thread == null) {
      return new Text('Could not find the thread.');
    }

    return new ThreadView(
      thread: thread,
      messageExpanded: (Message m) => emailStore.isMessageExpanded(m.id),
      onSelectMessage: (Message m) {
        emailStore.actions.toggleMessageExpansion(m.id);
      },
      onForwardMessage: _handleMessageAction,
      onReplyAllMessage: _handleMessageAction,
      onReplyMessage: _handleMessageAction,
      footer: new MessageActionBarFooter(
        message: thread.messages.last,
        onForwardMessage: _handleMessageAction,
        onReplyAllMessage: _handleMessageAction,
        onReplyMessage: _handleMessageAction,
      ),
      header: new ThreadActionBarHeader(
        thread: thread,
        onArchive: _handleThreadAction,
        onClose: onThreadClose ?? (_) => Navigator.pop(context),
        onMoreActions: _handleThreadAction,
        onDelete: _handleThreadAction,
      ),
    );
  }

  void _handleMessageAction(Message message) {
    print('Action Performed');
  }

  void _handleThreadAction(Thread thread) {
    print('Action Performed');
  }
}
