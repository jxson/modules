// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email/attachment.dart';
import 'package:module_toolkit/modular_widget.dart';
import 'package:module_toolkit/module_capability.dart';
import 'package:module_toolkit/module_data.dart';

/// Callback function signature for an action on an [Attachment]
typedef void AttachmentActionCallback(Attachment attachment);

/// Widget that renders an email [Attachment] that is type of
/// [AttachmentType.youtube].
///
/// This is intended to be a separate 'module' that should be 'chosen' to render
/// any Youtube attachments.
///
/// This module currently assumes that the data format for a Youtube attachment
/// will be the video ID. This probably unrealistic and we will need to provide
/// data adaptation to support real world experiences.
// TODO(dayang,rosswang): Look into data adaptation
class YoutubeAttachmentPreview extends StatelessWidget {
  /// Youtube email [Attachment]
  Attachment attachment;

  /// Callback if attachment preview is selected
  AttachmentActionCallback onSelect;

  /// Creates a [YoutubeAttachmentPreview] for a given email attachment
  YoutubeAttachmentPreview({Key key, @required this.attachment, this.onSelect})
      : super(key: key) {
    assert(this.attachment != null);
    // TODO(dayang): Is an Error more appropiate here?
    assert(this.attachment.type == AttachmentType.youtube);
  }

  /// Retrieves Youtube thumbnail from the video ID
  String _getYoutubeThumbnail(String id) {
    return 'http://img.youtube.com/vi/$id/0.jpg';
  }

  void _handleSelect() {
    if (onSelect != null) {
      onSelect(attachment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.white,
      child: new InkWell(
        onTap: _handleSelect,
        child: new Container(
          child: new Image.network(
            _getYoutubeThumbnail(attachment.content),
            fit: ImageFit.cover,
          ),
        ),
      ),
    );
  }
}

/// ModularWidgetBuilder for the YoutubeAttachmentPreview
class YoutubeAttachmentPreviewBuilder extends ModularWidgetBuilder {
  /// Constructor
  YoutubeAttachmentPreviewBuilder();

  @override
  Widget buildWidget(ModuleData data) {
    return new YoutubeAttachmentPreview(
      attachment: data.payload,
    );
  }

  @override
  BoxConstraints get boxConstraints =>
      new BoxConstraints.loose(new Size(400.0, 400.0));

  @override
  List<ModuleCapability> get desiredCapabilities => <ModuleCapability>[
        ModuleCapability.network,
        ModuleCapability.click,
      ];
}
