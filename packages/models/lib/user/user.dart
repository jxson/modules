// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// TODO(jxson): Document this.
class User {
  /// TODO(jxson): Document this.
  String name;
  /// TODO(jxson): Document this.
  String email;

  /// TODO(jxson): Document this.
  User({
    @required this.name,
    @required this.email, }) {
    assert(name != null);
    assert(email != null);
  }
}
