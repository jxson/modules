// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:widgets/youtube.dart';

/// Screen to showcase YoutubeThumbnail
class YoutubeThumbnailScreen extends StatelessWidget {
  /// Creates a [YoutubeThumbnailScreen] instance.
  YoutubeThumbnailScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Container(
        height: 150.0,
        width: 200.0,
        child: new YoutubeThumbnail(
          videoId: 'p336IIjZCl8',
        ),
      ),
    );
  }
}
