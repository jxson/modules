// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:config_flutter/config.dart';
import 'package:flutter/material.dart';
import 'package:widgets/usps.dart';

/// Adds all the [EmbeddedChildBuilder]s that this application supports.
Future<Null> addEmbeddedChildBuilders() async {
  // Get the config object.
  Config config = await Config.read('assets/config.json');

  // USPS Tracking.
  if (config.has('usps_api_key')) {
    kEmbeddedChildProvider.addEmbeddedChildBuilder(
      'usps-shipping',
      (dynamic args) {
        return new EmbeddedChild(
          widgetBuilder: (BuildContext context) => new TrackingStatus(
                apiKey: config.get('usps_api_key'),
                trackingCode: args,
              ),
          // Flutter version doesn't need a specific disposer.
          disposer: () {},
        );
      },
    );
  }
}
