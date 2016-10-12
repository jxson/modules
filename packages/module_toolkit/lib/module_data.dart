// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Represents a 'module data payload'
class ModuleData {
  /// Payload Type
  String type;

  /// Payload Content
  dynamic payload;

  /// Constructor
  ModuleData({
    this.type,
    this.payload,
  });
}
