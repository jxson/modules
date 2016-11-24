// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modular.lib.app.dart/app.dart';
import 'package:apps.modules.email.email_session/email_session.fidl.dart' as es;
import 'package:email_session_client/client.dart';
import 'package:email_session_store/email_session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:models/email.dart';
import 'package:widgets/email.dart';

const String _moduleName = 'email_list';
final ApplicationContext _context = new ApplicationContext.fromStartupInfo();
EmailSessionModule _module;

void _log(String msg) {
  print('[$_moduleName] $msg');
}

/// Temporary widget class for the list module.
class EmailListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            height: 73.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: new BoxDecoration(
              border: new Border(
                bottom: new BorderSide(
                  color: Colors.grey[200],
                  width: 1.0,
                ),
              ),
            ),
            child: new Row(
              children: <Widget>[
                new Text(
                  'Inbox',
                  overflow: TextOverflow.ellipsis,
                  style: new TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
          new Flexible(
            flex: 1,
            child: _buildThreadList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadList() {
    return new Block(children: <Widget>[
      new ThreadListItem(thread: new MockThread()),
      new ThreadListItem(thread: new MockThread()),
      new ThreadListItem(thread: new MockThread()),
    ]);
  }
}

void _created(EmailSessionModule module) {
  _module = module;
}

void _initialize(es.EmailSession service, EmailSessionLinkStore store) {
  // HACK: Global reference must be set before store is accessed by widgets.
  kEmailSessionStoreToken = new StoreToken(store);
}

void _stop(void callback()) {
  callback();
}

/// Main entry point to the email folder list module.
void main() {
  _log('Email list module started with context: $_context');
  addEmailSessionModule(_context, _moduleName, _created, _initialize, _stop);
  runApp(new MaterialApp(
    title: 'Email List Module',
    home: new EmailListScreen(),
    theme: new ThemeData(primarySwatch: Colors.blue),
    debugShowCheckedModeBanner: false,
  ));
}
