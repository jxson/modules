// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// This screen is a dummy screen.
/// TODO(youngseokyoon): implement real screens once the widgets are ready.
class DummyScreen extends StatelessWidget {
  /// Creates a [DummyScreen] instance.
  DummyScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Dummy Screen'),
      ),
      body: new Container(
        align: FractionalOffset.center,
        child: new Text('Dummy screen contents'),
      ),
    );
  }
}
