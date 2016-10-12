// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:models/email/attachment.dart';
import 'package:widgets/youtube/youtube_attachment_preview.dart';

import 'modular_widget.dart';
import 'module_capability.dart';
import 'module_data.dart';

/// Resolves modules based on the given Module Data, Module Capabilities and
/// layout BoxConstraints
///
/// For now the the ModuleResolver has the simple logic of selectin the
/// YoutubeAttachmentPreview if the data is an email attachment, and the
/// attachment itself is a Youtube video.
///
/// TODO (dayang): Add some examples of how the resolver might choose between
/// different modules.
class ModuleResolver {
  /// Resolves a ModuleWidgetBuilder given the module data payload and capabilities
  static Future<ModularWidgetBuilder> resolve({
    ModuleData data,
    List<ModuleCapability> capabilities,
    BoxConstraints boxConstraints,
  }) async {
    if (data.type != 'EmailAttachment' ||
        data.payload.type != AttachmentType.youtube) {
      return null;
    }
    // Wait a bit and then resolve the module to simulate a network call
    return new Future<YoutubeAttachmentPreviewBuilder>.delayed(
        const Duration(milliseconds: 10),
        () => new YoutubeAttachmentPreviewBuilder());
  }
}
