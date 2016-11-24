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
import 'package:models/user.dart';
import 'package:widgets/email.dart';

const String _moduleName = 'email_nav';
final ApplicationContext _context = new ApplicationContext.fromStartupInfo();
EmailSessionModule _module;

void _log(String msg) {
  print('[$_moduleName] $msg');
}

/// Temporary email menu screen to be displayed on the email_nav module on
/// fuchsia.
class EmailMenuScreen extends StatefulWidget {
  /// Creates a [EmailMenuScreen] instance.
  EmailMenuScreen({Key key}) : super(key: key);

  @override
  _EmailMenuScreenState createState() => new _EmailMenuScreenState();
}

class _EmailMenuScreenState extends State<EmailMenuScreen> {
  List<LabelGroup> _labelGroups;
  Label _selectLabel;
  User _user;

  @override
  void initState() {
    _labelGroups = <LabelGroup>[
      new LabelGroup(
        labels: <Label>[
          new Label(
            id: 'INBOX',
            name: 'Inbox',
            unread: 10,
            type: 'system',
          ),
          new Label(
            id: 'STARRED',
            name: 'Starred',
            unread: 5,
            type: 'system',
          ),
          new Label(
            id: 'DRAFT',
            name: 'Starred',
            unread: 0,
            type: 'system',
          ),
          new Label(
            id: 'TRASH',
            name: 'Trash',
            unread: 0,
            type: 'system',
          ),
        ],
      ),
      new LabelGroup(
        name: 'Work Labels',
        labels: <Label>[
          new Label(
            id: 'TODO',
            name: 'Todo',
            unread: 2,
            type: 'user',
          ),
          new Label(
            id: 'COMPLETED',
            name: 'Completed',
            unread: 2,
            type: 'user',
          ),
          new Label(
            id: 'JIRA',
            name: 'Jira',
            unread: 0,
            type: 'user',
          ),
          new Label(
            id: 'GERRIT',
            name: 'Gerrit',
            unread: 0,
            type: 'user',
          ),
        ],
      ),
    ];
    _user = new User(
      name: 'Coco Yang',
      email: 'littlePuppyCoco@puppy.cute',
    );
    super.initState();
  }

  void _handleSelectLabel(Label folder) {
    setState(() {
      _selectLabel = folder;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new InboxMenu(
        labelGroups: _labelGroups,
        onSelectLabel: _handleSelectLabel,
        selectedLabel: _selectLabel,
        user: _user,
      ),
    );
  }
}

void _created(EmailSessionModule module) {
  _module = module;
}

void _initialize(es.EmailSession service, EmailSessionLinkStore store) {
  // HACK: Global reference must be set before store is accessed by widgets.
  kEmailSessionStoreToken = new StoreToken(store);

  // Listen for changes to the email session
  store.listen((EmailSessionLinkStore store) {
    _log('GOT CHANGE TO MAX: ${store.fake}');
  });

  // Call the function defined in email_session.fidl.
  _log('Calling fakeAction(0)');
  service.fakeAction(0);
}

void _stop(void callback()) {
  _log('Stop callback called.');
  callback();
}

/// Main entry point to the email nav module.
void main() {
  _log('Email nav module started with context: $_context');
  addEmailSessionModule(_context, 'email_nav', _created, _initialize, _stop);
  runApp(new EmailMenuScreen());
}
