// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email/message.dart';
import 'package:models/email/thread.dart';

/// [ThreadParticipantList] is a [StatelessWidget]
///
/// A list that renders all the participants in an email thread.
/// Rules for participant rendereing:
///   1. Show list of users in thread in order of message creation
///   2. Do not repeat same users
///   3. Show number of messages in thread if there is > 1 message
///   4. Users that have unread messages in thread should be bolded
///   5. Always refer to the authenticated user as 'me'
class ThreadParticipantList extends StatelessWidget {
  /// The [Thread] to render particpants for
  final Thread thread;

  /// Creates a [ThreadParticipantList]
  ///
  /// Requires a [Thread] to render
  ThreadParticipantList({Key key, @required this.thread}) : super(key: key) {
    assert(thread != null);
  }

  @override
  Widget build(BuildContext context) {
    // Go through messages and record all participants and whether participants
    // have an unread message
    final LinkedHashMap<String, bool> participantToUnread =
        new LinkedHashMap<String, bool>();
    thread.messages.forEach((Message message) {
      if (!message.isRead) {
        participantToUnread[message.sender.displayText] = true;
      } else if (!participantToUnread.containsKey(message.sender)) {
        participantToUnread[message.sender.displayText] = false;
      }
    });

    // Create corresponding text span for every participant
    final List<TextSpan> participantTextSpanList = <TextSpan>[];
    int count = 0; //Have to manually track the count/index for inserting commas
    participantToUnread.forEach((String user, bool isUnread) {
      participantTextSpanList.add(new TextSpan(
        text: count < participantToUnread.length - 1 ? user + ', ' : user,
        style: new TextStyle(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          fontSize: 14.0,
          height: 1.4,
          color: Colors.black,
        ),
      ));
      count++;
    });

    final Widget participantText = new RichText(
      text: new TextSpan(
        children: participantTextSpanList,
      ),
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    );

    // Only should message count if thread has more than 1 message
    if (participantToUnread.length > 1) {
      return new SizedBox(
        height: 20.0,
        child: new CustomMultiChildLayout(
          delegate: new _ParticipantLayout(),
          children: <Widget>[
            new LayoutId(
              id: 'participantList',
              child: participantText,
            ),
            new LayoutId(
              id: 'messageCount',
              child: new Text(
                ' ${participantTextSpanList.length}',
                style: new TextStyle(
                  fontSize: 14.0,
                  height: 1.4,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return new SizedBox(
        height: 20.0,
        child: participantText,
      );
    }
  }
}

/// Layout Delegate that allows the participant text list to grow up to the
/// width of the parent while still accounting for the width of the message
/// count widget that follows.
class _ParticipantLayout extends MultiChildLayoutDelegate {
  _ParticipantLayout();

  static final String participantList = 'participantList';
  static final String messageCount = 'messageCount';

  @override
  void performLayout(Size size) {
    Size messageCountSize = layoutChild(messageCount, new BoxConstraints());
    Size participantListSize = layoutChild(participantList,
        new BoxConstraints(maxWidth: size.width - messageCountSize.width));
    positionChild(participantList, Offset.zero);
    positionChild(messageCount, new Offset(participantListSize.width, 0.0));
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}
