// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:config_flutter/config.dart';
import 'package:email_session_store/email_session_store_mock.dart';
import 'package:flutter/material.dart';

import 'gallery/home.dart';
import 'routes.dart';

/// An Application Widget.
///
/// The top-level widget for the gallery.
class App extends StatefulWidget {
  /// Creates an App.
  App({Key key, this.config}) : super(key: key);

  /// Config object to be used throughout the gallery app.
  final Config config;

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

    // Initialize the mock email session store here.
    kEmailSessionStoreToken ??= new StoreToken(new EmailSessionStoreMock());
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'FX Modules',
      theme: new ThemeData(primarySwatch: Colors.blue),
      routes: kRoutes,
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
