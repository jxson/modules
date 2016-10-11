// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';

import 'type_defs.dart';

/// Footer for a [Message] that contains quick actions
/// Actions are Reply, ReplyAll, and Foward
/// This footer will be typically found at the end of a individual ThreadView
class MessageActionBarFooter extends StatelessWidget {
  /// Given thread associated with this action bar
  Message message;

  /// Callback for selecting forward
  MessageActionCallback onForwardMessage;

  /// Callback for selecting reply all
  MessageActionCallback onReplyAllMessage;

  /// Callback for selecting reply
  MessageActionCallback onReplyMessage;

  /// Constructor to create a [MessageActionBarFooter]
  MessageActionBarFooter(
      {Key key,
      @required this.message,
      @required this.onForwardMessage,
      @required this.onReplyAllMessage,
      @required this.onReplyMessage})
      : super(key: key) {
    assert(message != null);
    assert(onForwardMessage != null);
    assert(onReplyAllMessage != null);
    assert(onReplyMessage != null);
  }

  void _handleForwardMessage() {
    onForwardMessage(message);
  }

  void _handleReplyAllMessage() {
    onReplyAllMessage(message);
  }

  void _handleReplyMessage() {
    onReplyMessage(message);
  }

  Widget _buildIconWithText({String text, IconData icon}) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Icon(icon),
        new Container(
          margin: const EdgeInsets.only(top: 8.0),
          child: new Text(
            text,
            style: new TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.white,
      child: new ButtonBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new MaterialButton(
            child: _buildIconWithText(
              text: 'REPLY',
              icon: Icons.reply,
            ),
            color: Colors.white,
            textColor: Colors.grey[400],
            onPressed: _handleReplyMessage,
            height: 50.0,
          ),
          new MaterialButton(
            child: _buildIconWithText(
              text: 'REPLY ALL',
              icon: Icons.reply_all,
            ),
            color: Colors.white,
            textColor: Colors.grey[400],
            onPressed: _handleReplyAllMessage,
            height: 50.0,
          ),
          new MaterialButton(
            child: _buildIconWithText(
              text: 'FORWARD',
              icon: Icons.forward,
            ),
            color: Colors.white,
            textColor: Colors.grey[400],
            onPressed: _handleForwardMessage,
            height: 50.0,
          ),
        ],
      ),
    );
  }
}
