// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';

typedef AttachmentPreviewSelected(Attachment attachment);

// abstract class AttachmentPreview extends StatelessWidget {
//   /// Email [Attachment]
//   Attachment attachment;
//
//   /// Callback if attachment preview is selected
//   AttachmentPreviewSelected onSelect;
//
//   AttachmentPreview({
//     Key key,
//     @required this.attachment,
//     @required this.onSelect
//   }) : super(key: key) {
//     assert(attachment != null);
//   }
//
//   void handleSelect() {
//     onSelect(attachment);
//   }
// }
