// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email/attachment.dart';

import 'type_defs.dart';

/// Widget that renders a generic 'fallback' email [Attachment] in the case
/// where no appropiate modules can be found.
///
/// This is intended to be a separate 'module' that is used as a 'fallback'
class FallbackAttachmentPreview extends StatelessWidget {
  /// Email [Attachment]
  Attachment attachment;

  /// Callback if attachment preview is selected
  AttachmentActionCallback onSelect;

  /// Creates a [FallbackAttachmentPreview] for a given email attachment
  FallbackAttachmentPreview({Key key, @required this.attachment, this.onSelect})
      : super(key: key) {
    assert(this.attachment != null);
  }

  void _handleSelect() {
    if (onSelect != null) {
      onSelect(attachment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.grey[200],
      child: new InkWell(
        onTap: _handleSelect,
        child: new Container(
          width: 200.0,
          height: 150.0,
          child: new Center(
            child: new Icon(
              Icons.attachment,
              color: Colors.grey[500],
              size: 40.0,
            ),
          ),
        ),
      ),
    );
  }
}
