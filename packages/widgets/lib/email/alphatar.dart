// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// [Alphatar] is a [StatelessWidget]
///
/// Alphatar is a 'circle avatar' to represent user profiles
/// If no avatar URL is given for an Alphatar, then the letter of the users name
/// along with a colored circle background will be used.
/// TODO(dayang) Allow Alphatar to fall back on letter representation is no
/// URL is given.
class Alphatar extends StatelessWidget {
  /// URL String pointing to the avatar image
  /// TODO(dayang) Handle both Network and Asset images for avatar use
  final String avatarUrl;

  /// Size of alphatar. Default is 40.0
  final double size;

  /// Creates a Alphatar
  ///
  /// Requires a avatar URL
  Alphatar({Key key, @required this.avatarUrl, this.size: 40.0})
      : super(key: key) {
    assert(avatarUrl != null);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: size,
      height: size,
      child: new ClipOval(
        child: new Image.network(
          avatarUrl,
          width: size,
          height: size,
          fit: ImageFit.cover,
        ),
      ),
    );
  }
}
