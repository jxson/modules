// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:widgets/usps.dart';

import '../src/config.dart';

/// Adds all the [EmbeddedChildBuilder]s that this application supports.
void addEmbeddedChildBuilders() {
  // USPS Tracking.
  try {
    String uspsApiKey = kConfig.get('usps_api_key');
    kEmbeddedChildProvider.addEmbeddedChildBuilder(
      'usps-shipping',
      (dynamic args) {
        return new EmbeddedChild(
          widgetBuilder: (BuildContext context) => new TrackingStatus(
                apiKey: uspsApiKey,
                trackingCode: args,
              ),
          // Flutter version doesn't need a specific disposer.
          disposer: () {},
        );
      },
    );
  } catch (e) {
    // TODO(youngseokyoon): use the config_flutter package instead for getting
    // the 'usps_api_key' value.
    // https://fuchsia.atlassian.net/browse/SO-140
    print('Warning: $e');
  }
}
