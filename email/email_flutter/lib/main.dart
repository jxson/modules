// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:email_session/email_session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'email_session_store_direct.dart';
import 'quarterback.dart';

Future<Null> main() async {
  // HACK(alangardner): Must be called before any flux flutter widgets are setup
  // This sets up a global variable that is accessible to all of the widgets.
  EmailSessionStoreDirect emailSessionStore = new EmailSessionStoreDirect();
  kEmailSessionStoreToken = new StoreToken(emailSessionStore);
  runApp(new _MyApp());
  await emailSessionStore.fetchInitialContentWithGmailApi();
}

class _MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting
        // the app, try changing the primarySwatch below to Colors.green
        // and press "r" in the console where you ran "flutter run".
        // We call this a "hot reload". Notice that the counter didn't
        // reset back to zero -- the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new EmailQuarterbackModule(),
    );
  }
}
