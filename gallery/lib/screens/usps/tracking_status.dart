// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:widgets/usps.dart';

/// Screen to showcase YoutubePlayer
class TrackingStatusScreen extends StatelessWidget {
  /// Creates a [TrackingStatusScreen] instance.
  TrackingStatusScreen({
    Key key,
    this.uspsApiKey,
    this.mapsApiKey,
  })
      : super(key: key);

  /// API key for USPS
  final String uspsApiKey;

  /// API key for Google Maps
  final String mapsApiKey;

  @override
  Widget build(BuildContext context) {
    return new Block(
      children: <Widget>[
        new Center(
          child: new TrackingStatus(
            trackingCode: '9374889676090175041871',
            apiKey: uspsApiKey,
            mapsApiKey: mapsApiKey,
          ),
        ),
      ],
    );
  }
}
