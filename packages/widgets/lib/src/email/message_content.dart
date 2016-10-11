// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';

/// Renders the content of a [Message]
// TODO(dayang) Render rich text
class MessageContent extends StatelessWidget {
  /// [Message] to render content for
  Message message;

  /// Creates a new MessageContent widget
  MessageContent({Key key, @required this.message}) : super(key: key) {
    assert(message != null);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),
      child: new Text(
        message.text,
        softWrap: true,
        style: new TextStyle(
          fontSize: 16.0,
          color: Colors.black,
          height: 1.5,
        ),
      ),
    );
  }
}
