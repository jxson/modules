// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';

import 'type_defs.dart';

/// Google Inbox style action header for email editor that is used to compose
/// a new [Message] which has affordances to close, attach files and send.
// TODO(dayang): Figure out if the Message model should be extended so that
// there is this concept of a Message Draft.
class EditorActionBarHeader extends StatelessWidget {
  /// [Message] that is being composed
  Message message;

  /// Callback for 'close' affordance
  MessageActionCallback onClose;

  /// Callback for sending message
  MessageActionCallback onSend;

  /// Callback for 'attach file' affordance
  MessageActionCallback onAttach;

  /// Flag on whether to 'enable' send button.
  bool enableSend;

  /// Creates a new [EditorActionBarHeader]
  EditorActionBarHeader(
      {Key key,
      this.enableSend: false,
      @required this.message,
      @required this.onAttach,
      @required this.onClose,
      @required this.onSend})
      : super(key: key) {
    assert(this.message != null);
    assert(this.onAttach != null);
    assert(this.onClose != null);
    assert(this.onSend != null);
  }

  void _handleClose() {
    onClose(message);
  }

  void _handleSend() {
    onSend(message);
  }

  void _handleAttach() {
    onAttach(message);
  }

  /// Builds row of buttons for header
  Widget _buildButtonRow() {
    return new Row(
      children: <Widget>[
        new Flexible(
          flex: null,
          child: new ButtonBar(
            children: <Widget>[
              new IconButton(
                icon: new Icon(Icons.close),
                onPressed: _handleClose,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        new Flexible(
          flex: 1,
          child: new ButtonBar(
            alignment: MainAxisAlignment.end,
            children: <Widget>[
              new IconButton(
                icon: new Icon(Icons.attach_file),
                onPressed: _handleAttach,
                color: Colors.grey[600],
              ),
              new IconButton(
                icon: new Icon(Icons.send),
                onPressed: enableSend ? _handleSend : null,
                color: Colors.blue[500],
                disabledColor: Colors.grey[300],
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.white,
      child: new Container(
        child: _buildButtonRow(),
        decoration: new BoxDecoration(
          border: new Border(
            bottom: new BorderSide(
              color: Colors.grey[200],
              width: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
