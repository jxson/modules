// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:intl/intl.dart';
import 'package:util/time_util.dart';

/// Represents a single Gmail Message
/// https://developers.google.com/gmail/api/v1/reference/users/messages
class Message {
  // TODO(dayang) Most of these are 'fake stub' fields that are used for
  // prototying. We will have to update this once we get real Gmail data.

  /// Unique Identifier for given email message
  String id;

  /// List of recipients email message was sent to
  List<String> recipientList;

  /// List of users who are CCed in email message
  List<String> ccList;

  /// Email address of sender
  String sender;

  /// URL pointing to Avatar of sender
  String senderProfileUrl;

  /// Subject line of email
  String subject;

  /// Main body text of email
  String text;

  /// Time that Email was received
  DateTime timestamp;

  /// True if Email Message has been read
  bool isRead;

  /// Constructor
  Message({
    this.id,
    this.sender,
    this.senderProfileUrl,
    this.recipientList: const <String>[],
    this.ccList: const <String>[],
    this.subject,
    this.text,
    this.timestamp,
    this.isRead,
  });

  // TODO(dayang) Generate text snippet preview of conversation. Need to remove
  // new line characters for proper formatting.
  /// Generates preview text for message
  String generateSnippet() {
    return text;
  }

  /// Get 'Display Date' for [Message]
  ///
  /// Rules for Display Date:
  /// 1. Show minutes/hour/am-pm for timestamps in the same day.
  ///    Ex: 10:44 pm
  /// 2. Show month abbreviation + day for timestamps not in the same day.
  ///    Ex. Aug 15
  String getDisplayDate({DateTime relativeTo}) {
    if (relativeTo == null) {
      relativeTo = new DateTime.now();
    }
    if (TimeUtil.isSameDay(relativeTo, timestamp)) {
      return new DateFormat.jm().format(timestamp);
    } else {
      return new DateFormat.MMMd().format(timestamp);
    }
  }
}
