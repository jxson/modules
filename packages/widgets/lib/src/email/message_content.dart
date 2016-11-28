// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';

import '../common/embedded_child.dart';

const double _kEmbeddedChildHeight = 800.0;

/// Renders the content of a [Message]
// TODO(dayang) Render rich text
class MessageContent extends StatefulWidget {
  /// [Message] to render content for
  final Message message;

  /// Creates a new MessageContent widget
  MessageContent({
    Key key,
    @required this.message,
  })
      : super(key: key) {
    assert(message != null);
  }

  @override
  _MessageContentState createState() => new _MessageContentState();
}

class _MessageContentState extends State<MessageContent> {
  /// List of [EmbeddedChild] for displaying attachments in separate modules.
  final List<EmbeddedChild> embeddedChildren = <EmbeddedChild>[];

  @override
  void initState() {
    super.initState();
    config.message.attachments.forEach((Attachment attachment) {
      try {
        switch (attachment.type) {
          case AttachmentType.uspsShipping:
            embeddedChildren.add(
              kEmbeddedChildProvider.buildEmbeddedChild(
                'usps-shipping',
                attachment.value,
              ),
            );
            break;

          case AttachmentType.youtubeVideo:
            embeddedChildren.add(
              kEmbeddedChildProvider.buildEmbeddedChild(
                'youtube-video',
                attachment.value,
              ),
            );
            break;
        }
      } catch (e) {
        print('Error occurred while building embedded child for attachment '
            '${attachment.id}: $e');
      }
    });
  }

  @override
  void dispose() {
    // Dispose all the embedded children.
    embeddedChildren.forEach((EmbeddedChild ec) => ec.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[
      new Text(
        config.message.text,
        softWrap: true,
        style: new TextStyle(
          fontSize: 16.0,
          color: Colors.black,
          height: 1.5,
        ),
      ),
    ];

    embeddedChildren.forEach((EmbeddedChild ec) {
      children.add(new SizedBox(
        height: _kEmbeddedChildHeight,
        child: new Card(
          color: Colors.grey[200],
          child: ec.widgetBuilder(context),
        ),
      ));
    });

    return new Container(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),
      child: new Column(
        children: children,
      ),
    );
  }
}
