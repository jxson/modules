// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:widgets/map.dart';

/// Screen to showcase the StaticMap widget
class StaticMapScreen extends StatelessWidget {
  /// Creates a [StaticMapScreen] instance.
  StaticMapScreen({
    Key key,
    this.apiKey,
  })
      : super(key: key);

  /// API key for maps
  final String apiKey;

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new StaticMap(
        width: 300.0,
        height: 300.0,
        zoom: 15,
        location: '56 Henry, San Francisco, CA',
        apiKey: apiKey,
      ),
    );
  }
}
