// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:widgets_meta/widgets_meta.dart';

/// Google Inbox style action header for the email editor
///
/// Contains affordances for:
/// - adding an attachment
/// - closing the editor
/// - sending the email
@ExampleSize(600.0, 70.0)
class EditorActionBarHeader extends StatelessWidget {
  /// Callback for 'attach file' affordance
  final VoidCallback onAttach;

  /// Callback for 'close' affordance
  final VoidCallback onClose;

  /// Callback for sending message
  final VoidCallback onSend;

  /// Flag on whether to 'enable' send button.
  final bool enableSend;

  /// Creates a new [EditorActionBarHeader]
  EditorActionBarHeader({
    Key key,
    this.enableSend: false,
    this.onAttach,
    this.onClose,
    this.onSend,
  })
      : super(key: key);

  void _handleClose() {
    onClose?.call();
  }

  void _handleSend() {
    onSend?.call();
  }

  void _handleAttach() {
    onAttach?.call();
  }

  /// Builds row of buttons for header
  Widget _buildButtonRow() {
    return new Row(
      children: <Widget>[
        new Expanded(
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
        new Expanded(
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
