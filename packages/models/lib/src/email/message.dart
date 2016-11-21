// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert' show UTF8, BASE64;

import 'package:collection/collection.dart';
import 'package:email_api/api.dart' as api;
import 'package:intl/intl.dart';
import 'package:quiver/core.dart' as quiver;
import 'package:util/extract_uri.dart';
import 'package:util/time_util.dart';

import 'attachment.dart';
import 'mailbox.dart';

const ListEquality<Mailbox> _mailboxListEquality =
    const ListEquality<Mailbox>(const DefaultEquality<Mailbox>());

/// Represents a single Gmail Message
/// https://developers.google.com/gmail/api/v1/reference/users/messages
class Message {
  /// Unique Identifier for given email message
  final String id;

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
  final Set<Uri> links;

  /// List of attachments for given email
  final List<Attachment> attachments;

  /// Time that Email was received
  final DateTime timestamp;

  /// True if Email Message has been read
  final bool isRead;

  /// Constructor
  Message({
    this.id,
    this.sender,
    this.senderProfileUrl,
    this.recipientList: const <Mailbox>[],
    this.ccList: const <Mailbox>[],
    this.subject,
    this.text,
    this.links,
    this.attachments,
    this.timestamp,
    this.isRead,
  });

  /// Create a [Message] from a Gmail API Message model
  /// Use plain-text representation (if it isgiven in the message payload)
  /// otherwise use the Gmail snippet as the message text
  factory Message.fromGmailApi(api.Message message) {
    String subject = '';
    Mailbox sender;
    String messageText;
    List<Mailbox> recipientList = <Mailbox>[];
    List<Mailbox> ccList = <Mailbox>[];
    bool isRead = !message.labelIds.contains('UNREAD');
    DateTime timestamp = new DateTime.fromMillisecondsSinceEpoch(
        int.parse(message.internalDate));

    // Go through message headers and retrieve message information
    message.payload.headers.forEach((api.MessagePartHeader header) {
      switch (header.name.toLowerCase()) {
        case 'from':
          sender = new Mailbox.fromString(header.value);
          break;
        case 'to':
          header.value.split(', ').forEach((String rawAddress) {
            recipientList.add(new Mailbox.fromString(rawAddress));
          });
          break;
        case 'cc':
          header.value.split(', ').forEach((String rawAddress) {
            ccList.add(new Mailbox.fromString(rawAddress));
          });
          break;
        case 'subject':
          subject = header.value;
          break;
      }
    });

    // Look for plain-text message representation in the message parts
    message.payload.parts?.forEach((api.MessagePart messagePart) {
      if (messagePart.mimeType == 'text/plain') {
        messageText = UTF8.decode(BASE64.decode(messagePart.body.data));
      }
    });

    // Fallback to Gmail generated snippet if not plain-text
    if (messageText == null) {
      messageText = message.snippet;
    }

    /// Add any youtube and usps links as attachments
    List<Attachment> attachments = <Attachment>[];
    Set<Uri> links = extractURI(messageText);
    links.forEach((Uri uri) {
      if (uri.host == 'www.youtube.com' &&
          uri.path == '/watch' &&
          uri.queryParameters['v'] != null) {
        attachments.add(new Attachment(
          type: AttachmentType.youtubeVideo,
          value: uri.queryParameters['v'],
        ));
      } else if (uri.host == 'tools.usps.com' &&
          uri.path == '/go/TrackConfirmAction' &&
          uri.queryParameters['qtc_tLabels1'] != null) {
        attachments.add(new Attachment(
          type: AttachmentType.uspsShipping,
          value: uri.queryParameters['qtc_tLabels1'],
        ));
      }
    });

    return new Message(
      id: message.id,
      subject: subject,
      sender: sender,
      senderProfileUrl: null,
      recipientList: recipientList,
      ccList: ccList,
      text: messageText,
      links: links,
      attachments: attachments,
      timestamp: timestamp,
      isRead: isRead,
    );
  }

  /// Generates preview text for message
  /// Strips all newline characters
  // TODO(dayang): Trim NewLine characters for other platforms
  // https://fuchsia.atlassian.net/browse/SO-131
  String generateSnippet() {
    return text.replaceAll('\n', ' ');
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
