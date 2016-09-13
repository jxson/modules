// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

void main() {
  runApp(new App());
}

/// An Application Widget.
///
/// The top-level widget for the gallery.
class App extends StatelessWidget {
  /// Creates an App.
  App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext content) {
    return new MaterialApp(
      title: 'FX Modules',
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: new Scaffold(
        appBar: new AppBar(title: new Text('FX Modules')),
        body: new Text('Gallery screen should be put here.'),
      ),
    );
  }
}
