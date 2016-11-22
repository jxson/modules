// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:email_session_store/email_session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:models/email.dart';
import 'package:widgets/email.dart';

/// An email thread screen that shows all the messages in a particular email
/// [Thread], built with the flux pattern.
class EmailThreadScreen extends StoreWatcher {
  /// Creates a new [EmailThreadScreen] instance.
  EmailThreadScreen({
    Key key,
  })
      : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(kEmailSessionStoreToken);
  }

  @override
  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    final EmailSessionStore emailSession = stores[kEmailSessionStoreToken];

    return new Center(child: _buildBody(context, emailSession));
  }

  Widget _buildBody(BuildContext context, EmailSessionStore emailSession) {
    if (emailSession.fetchingThreads) {
      return new CircularProgressIndicator();
    }

    if (emailSession.currentErrors.isNotEmpty) {
      // TODO(alangardner): Show more than the first error
      return new Text('Error occurred while retrieving email threads: '
          '${emailSession.currentErrors.first}');
    }

    Thread thread = emailSession.focusedThread;
    if (thread == null) {
      return new Text('No Thread Selected');
    }

    return new ThreadView(
      thread: thread,
      messageExpanded: (Message m) => emailSession.messageIsExpanded(m),
      onSelectMessage: emailSessionToggleMessageExpand.call,
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
