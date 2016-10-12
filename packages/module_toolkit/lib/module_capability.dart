// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Types of capabilities that a 'parent module' can give to a child module
/// in an embedded surface.
///
/// Capabilities are 'hard' in that the child module's runtime does not allow
/// these 'system calls' to be made.
///
/// This is designed to reflect Fuchsia/Magenta's capability based model
enum ModuleCapability {
  /// Child module can have network access
  network,

  /// Child module can do audio playback
  audio,

  /// Child module can do video playback
  video,

  /// Child module can have touch/tap/click events
  click,
}
