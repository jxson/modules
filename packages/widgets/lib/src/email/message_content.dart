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
              kEmbeddedChildProvider.buildGeneralEmbeddedChild(
                docRoot: 'usps-doc',
                type: 'usps-shipping',
                moduleUrl: 'file:///system/apps/usps',
                propKey: 'usps-tracking-key',
                value: attachment.value,
              ),
            );
            break;

          case AttachmentType.youtubeVideo:
            embeddedChildren.add(
              kEmbeddedChildProvider.buildGeneralEmbeddedChild(
                docRoot: 'youtube-doc',
                type: 'youtube-video',
                moduleUrl: 'file:///system/apps/youtube_video',
                propKey: 'youtube-video-id',
                value: attachment.value,
              ),
            );
            break;

          case AttachmentType.orderReceipt:
            embeddedChildren.add(
              kEmbeddedChildProvider.buildGeneralEmbeddedChild(
                type: 'order-receipt',
                moduleUrl: 'file:///system/apps/interactive_receipt_http',
                value: null,
              ),
            );
        }
      } catch (e) {
        embeddedChildren.add(
          new EmbeddedChild(
            widgetBuilder: (_) => new Text('Error occurred while building '
                'embedded child for attachment ${attachment.toJson()}: $e'),
          ),
        );
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
        config.message.text ?? '',
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
        child: new Align(
          alignment: FractionalOffset.topCenter,
          child: new Card(
            color: Colors.grey[200],
            child: ec.widgetBuilder(context),
          ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
