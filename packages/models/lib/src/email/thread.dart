// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:quiver/core.dart' as quiver;

import 'attachment.dart';
import 'message.dart';

/// Represents a single Gmail Thread
/// https://developers.google.com/gmail/api/v1/reference/users/threads#resource
class Thread {
  /// The unique ID of the thread (provided by Gmail)
  String id;

  /// A short part of the message text (provided by Gmail)
  String snippet;

  /// The ID of the last history record that modified this thread (provided by Gmail)
  String historyId;

  /// The list of messages in the thread (provided by Gmail)
  List<Message> messages;

  /// Constructor
  Thread({
    this.id,
    this.snippet,
    this.historyId,
    this.messages,
  });

  /// Gets the subject of the thread
  /// For now, this will return the subject of the first message of the thread
  /// If there is no subject specified, a default of '(no subject)' will be set
  // TODO (dayang): Figure out how the thread subject is determined based on
  // Gmail APIs
  String getSubject() {
    if (this.messages.isNotEmpty &&
        this.messages[0].subject != null &&
        this.messages[0].subject.isNotEmpty) {
      return this.messages[0].subject;
    } else {
      return '(No Subject)';
    }
  }

  @override
  bool operator ==(Object o) =>
      o is Thread &&
      o.id == id &&
      o.snippet == snippet &&
      o.historyId == historyId &&
      const ListEquality<Message>().equals(o.messages, messages);

  @override
  int get hashCode => quiver.hashObjects(<dynamic>[
        id,
        snippet,
        historyId,
        messages,
      ]);

  /// Get all [Attachment]s in all messages of thread
  Iterable<Attachment> get attachments =>
      messages.expand((Message m) => m.attachments);
}
