// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';

import 'preview.dart';

class YoutubeAttachment extends StatelessWidget {
  /// Email [Attachment]
  Attachment attachment;

  YoutubeAttachment({
    Key key,
    @required this.id,
    @required this.attachment,
    @required this.onSelect
  }) : super(key: key);
}

class YoutubeAttachmentPreview extends StatelessWidget {
  /// Email [Attachment]
  Attachment attachment;

  String id;

  /// Callback if attachment preview is selected
  AttachmentPreviewSelected onSelect;

  /// Creates a [YoutubeAttachmentPreview] for a given email attachment
  YoutubeAttachmentPreview({
    Key key,
    @required this.id,
    @required this.attachment,
    @required this.onSelect
  }) : super(key: key);

  static render({ Key key, String id }) {
    return new YoutubeAttachmentPreview(key: key, id: id);
  }

  void _handleSelect() {
    onSelect(attachment);
  }

  /// Retrieves Youtube thumbnail from the video ID
  String get thumbnail {
    return 'http://img.youtube.com/vi/$id/0.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.white,
      child: new InkWell(
        onTap: _handleSelect,
        child: new Container(
          child: new Image.network(
            thumbnail,
            fit: ImageFit.cover,
          ),
        ),
      ),
    );
  }
}
