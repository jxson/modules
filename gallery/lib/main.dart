// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flux/email.dart';
import 'package:models/email.dart';

import 'gallery/home.dart';
import 'routes.dart';

void main() {
  runApp(new App());
}

/// An Application Widget.
///
/// The top-level widget for the gallery.
class App extends StatefulWidget {
  /// Creates an App.
  App({Key key}) : super(key: key);

  @override
  AppState createState() => new AppState();
}

/// The Application State.
class AppState extends State<App> {
  /// Indicates whether the performance overlay should be shown.
  ///
  /// This state should be kept at this top level, because it needs to be passed
  /// as one of the MaterialApp constructor arguments.
  bool showPerformanceOverlay = false;

  @override
  void initState() {
    super.initState();

    // Initialize the stores here.
    // The following line is put here to make sure that the store is initialized
    // before the updateThreadsAction is dispatched.
    kEmailStoreToken;
    kEmailActions.updateThreads(<Thread>[
      new MockThread(id: 'thread01'),
      new MockThread(id: 'thread02'),
      new MockThread(id: 'thread03'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'FX Modules',
      theme: new ThemeData(primarySwatch: Colors.blue),
      routes: kRoutes,
      onGenerateRoute: handleRoute,
      home: new Home(
        showPerformanceOverlay: showPerformanceOverlay,
        onShowPerformanceOverlayChanged: (bool value) {
          setState(() {
            showPerformanceOverlay = value;
          });
        },
      ),
      showPerformanceOverlay: showPerformanceOverlay,
    );
  }
}
