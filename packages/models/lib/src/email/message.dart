// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:quiver/core.dart' as quiver;
import 'package:util/time_util.dart';
import 'package:widgets_meta/widgets_meta.dart';

import '../fixtures/fixtures.dart';
import 'attachment.dart';
import 'mailbox.dart';

const ListEquality<Mailbox> _mailboxListEquality =
    const ListEquality<Mailbox>(const DefaultEquality<Mailbox>());

/// Represents a single Gmail Message
/// https://developers.google.com/gmail/api/v1/reference/users/messages
@Generator(ModelFixtures, 'message')
class Message {
  /// Unique Identifier for given email message
  final String id;

  /// Unique Identifier for the thread that contains this message
  final String threadId;

  /// List of recipient mailboxes
  final List<Mailbox> recipientList;

  /// List of mailboxes that are CCed in email message
  final List<Mailbox> ccList;

  /// Mailbox of sender
  final Mailbox sender;

  /// URL pointing to Avatar of sender
  final String senderProfileUrl;

  /// Subject line of email
  final String subject;

  /// Main body text of email
  final String text;

  /// List of links (URIs) that are found within email
  final List<Uri> links;

  /// List of attachments for given email
  final List<Attachment> attachments;

  /// Time that Email was received
  final DateTime timestamp;

  /// True if Email Message has been read
  final bool isRead;

  /// Constructor
  Message({
    this.id,
    this.threadId,
    this.sender,
    this.senderProfileUrl,
    this.subject,
    this.text,
    this.timestamp,
    this.isRead,
    List<Uri> links,
    List<Attachment> attachments,
    List<Mailbox> recipientList,
    List<Mailbox> ccList,
  })
      : links = new List<Uri>.unmodifiable(links ?? <Uri>[]),
        attachments =
            new List<Attachment>.unmodifiable(attachments ?? <Attachment>[]),
        recipientList =
            new List<Mailbox>.unmodifiable(recipientList ?? <Mailbox>[]),
        ccList = new List<Mailbox>.unmodifiable(ccList ?? <Mailbox>[]);

  /// Create a message from JSON.
  factory Message.fromJson(Map<String, dynamic> json) {
    int ms = json['timestamp'];
    DateTime _timestamp = new DateTime.fromMillisecondsSinceEpoch(ms);

    Iterable<Uri> links = json['links']?.map((String link) => Uri.parse(link));

    Iterable<Attachment> attachments = json['attachments']
        ?.map((Map<String, dynamic> a) => new Attachment.fromJson(a));

    Iterable<Mailbox> to =
        json['to']?.map((Map<String, dynamic> u) => new Mailbox.fromJson(u));

    Iterable<Mailbox> cc =
        json['cc']?.map((Map<String, dynamic> u) => new Mailbox.fromJson(u));

    return new Message(
      id: json['id'],
      threadId: json['threadId'],
      sender: new Mailbox.fromJson(json['sender']),
      senderProfileUrl: json['senderProfileUrl'],
      subject: json['subject'],
      text: json['text'],
      timestamp: _timestamp,
      isRead: json['isRead'],
      links: links != null ? links.toList() : const <Uri>[],
      attachments: attachments != null ? attachments.toList() : const <Uri>[],
      recipientList: to != null ? to.toList() : const <Mailbox>[],
      ccList: cc != null ? cc.toList() : const <Mailbox>[],
    );
  }

  /// Helper function for JSON.encode() creates JSON-encoded Thread object.
  Map<String, dynamic> toJson() {
    // TODO(jxson): MailBox models should be moved to User models, MailBox
    // representation should then user the standard User model for it's
    // backing data.
    Map<String, dynamic> json = <String, dynamic>{
      'id': id,
      'threadId': threadId,
      'sender': sender.toJson(),
      'senderProfileUrl': senderProfileUrl,
      'subject': subject,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'links': links.map((Uri l) => l.toString()).toList(),
      'to': recipientList.map((Mailbox r) => r.toJson()).toList(),
      'cc': ccList.map((Mailbox r) => r.toJson()).toList(),
      'attachments': attachments.map((Attachment a) => a.toJson()).toList(),
    };

    return json;
  }

  // Message, as a [String].
  @override
  String toString() {
    return 'Message('
        'id: $id"'
        ')';
  }

  /// Generates preview text for message
  ///
  /// Strips all newline characters
  String generateSnippet() {
    return (text ?? '').replaceAll('\r\n', ' ').replaceAll('\n', ' ');
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

  @override
  bool operator ==(Object o) =>
      o is Message &&
      o.id == id &&
      o.sender == sender &&
      o.senderProfileUrl == senderProfileUrl &&
      _mailboxListEquality.equals(o.recipientList, recipientList) &&
      _mailboxListEquality.equals(o.ccList, ccList) &&
      o.subject == subject &&
      o.text == text &&
      o.timestamp == timestamp &&
      o.isRead == isRead;

  @override
  int get hashCode => quiver.hashObjects(<dynamic>[
        id,
        sender,
        senderProfileUrl,
        recipientList,
        ccList,
        subject,
        text,
        timestamp,
        isRead,
      ]);
}
