// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:widgets/youtube.dart';

/// Screen to showcase YoutubePlayer
class YoutubePlayerScreen extends StatelessWidget {
  /// Creates a [YoutubePlayerScreen] instance.
  YoutubePlayerScreen({
    Key key,
    this.apiKey,
  })
      : super(key: key);

  /// Youtube API key
  final String apiKey;

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new YoutubeVideo(
        videoId: 'a6KGPBflhiM',
        apiKey: apiKey,
      ),
    );
  }
}
