// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:lib.fidl.dart/bindings.dart' as bindings;
import 'package:email_api/email_api.dart';
import 'package:models/email.dart';

import '../fidls.dart' as fidl;
import 'api.dart';

/// Implementation for email_service.
class ThreadsImpl extends fidl.Threads {
  final fidl.ThreadsBinding _binding = new fidl.ThreadsBinding();

  /// Binds this implementation to the incoming [InterfaceRequest].
  ///
  /// This should only be called once. In other words, a new [ThreadsImpl]
  /// object needs to be created per interface request.
  void bind(bindings.InterfaceRequest<fidl.Threads> request) {
    _binding.bind(this, request);
  }

  @override
  Future<Null> list(
      String labelId,
      int max,
      void callback(
    List<fidl.Thread> threads,
  )) async {
    EmailAPI api = await API.get();
    List<Thread> threads = await api.threads(
      labelId: labelId,
      max: max,
    );

    List<fidl.Thread> results = threads.map((Thread thread) {
      return new fidl.Thread.init(
          thread.id,
          thread.snippet,
          thread.historyId,
          thread.messages.map((Message message) {
            fidl.User sender = new fidl.User()
              ..email = message.sender.address
              ..name = message.sender.displayName;

            List<fidl.User> recipients =
                message.recipientList.map((Mailbox recipient) {
              return new fidl.User()
                ..email = recipient.address
                ..name = recipient.displayName;
            }).toList();

            List<fidl.User> cc = message.ccList.map((Mailbox recipient) {
              return new fidl.User()
                ..email = recipient.address
                ..name = recipient.displayName;
            }).toList();

            List<fidl.Attachment> attachments =
                message.attachments.map((Attachment attachment) {
              return new fidl.Attachment()
                ..id = attachment.id
                ..type = attachment.id
                ..value = attachment.value;
            }).toList();

            return new fidl.Message.init(
              message.id,
              message.timestamp.millisecondsSinceEpoch,
              message.isRead,
              sender,
              message.subject,
              recipients,
              cc,
              message.text,
              message.links.map((Uri link) => link.toString()),
              attachments,
            );
          }).toList());
    }).toList();

    callback(results);
    return null;
  }
}
