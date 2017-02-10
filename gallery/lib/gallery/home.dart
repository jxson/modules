// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'collection.dart';
import 'drawer.dart';

/// This [Widget] displays the homepage of the gallery.
class Home extends StatefulWidget {
  /// Creates an instance of [Home].
  Home({
    Key key,
    this.showPerformanceOverlay,
    this.onShowPerformanceOverlayChanged,
  })
      : super(key: key);

  /// Indicates whether the performance overlay should be shown.
  bool showPerformanceOverlay = false;

  /// A callback function to be called when the 'Performance Overlay' checkbox
  /// value is changed.
  ValueChanged<bool> onShowPerformanceOverlayChanged;

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('FX Modules')),
      body: new ListView(children: kGalleryCollection),
      drawer: new GalleryDrawer(
        showPerformanceOverlay: config.showPerformanceOverlay,
        onShowPerformanceOverlayChanged: config.onShowPerformanceOverlayChanged,
      ),
    );
  }
}
