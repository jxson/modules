// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// UI Widget that renders a Google Map given a location
class StaticMap extends StatelessWidget {
  /// Location to show
  final String location;

  /// How much to zoom in for given location
  final int zoom;

  /// Width of map
  final double width;

  /// Height of map
  final double height;

  /// API key for Google Maps
  final String apiKey;

  /// Constructor
  StaticMap({
    Key key,
    @required this.apiKey,
    @required this.location,
    this.zoom: 5,
    this.width: 300.0,
    this.height: 300.0,
  })
      : super(key: key) {
    assert(location != null);
    assert(apiKey != null);
  }

  @override
  Widget build(BuildContext context) {
    String mapUrl = 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=$location&scale=2'
        '&zoom=$zoom&size=${width.round()}x${height.round()}'
        '&maptype=roadmap&markers=color:red%7Clabel:P%7C'
        '${Uri.encodeQueryComponent(location)}'
        '&key=$apiKey';
    return new Image.network(
      mapUrl,
      height: height,
      width: width,
      gaplessPlayback: true,
      fit: ImageFit.cover,
    );
  }
}
