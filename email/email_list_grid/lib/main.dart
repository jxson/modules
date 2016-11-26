// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modular.lib.app.dart/app.dart';
import 'package:apps.modules.email.email_session/email_session.fidl.dart' as es;
import 'package:email_session_client/client.dart';
import 'package:email_session_store/email_session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:widgets/email.dart';

const String _moduleName = 'email_grid_list';
final ApplicationContext _context = new ApplicationContext.fromStartupInfo();
EmailSessionModule _module;

void _log(String msg) {
  print('[$_moduleName] $msg');
}

void _created(EmailSessionModule module) {
  _module = module;
}

void _initialize(es.EmailSession service, EmailSessionLinkStore store) {
  // HACK: Global reference must be set before store is accessed by widgets.
  kEmailSessionStoreToken = new StoreToken(store);

  runApp(new MaterialApp(
    title: 'Email List Grid Module',
    home: new EmailListScreen(style: InboxStyle.gridView),
    theme: new ThemeData(primarySwatch: Colors.blue),
    debugShowCheckedModeBanner: false,
  ));
}

void _stop(void callback()) {
  callback();
}

/// Main entry point to the email list grid module.
void main() {
  _log('Email grid list module started with context: $_context');
  addEmailSessionModule(_context, _moduleName, _created, _initialize, _stop);
}
