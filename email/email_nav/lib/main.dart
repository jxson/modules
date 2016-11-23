// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modular.lib.app.dart/app.dart';
import 'package:apps.modular.services.application/service_provider.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modular.services.story/module.fidl.dart';
import 'package:apps.modular.services.story/story.fidl.dart';
import 'package:flutter/material.dart';
import 'package:lib.fidl.dart/bindings.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';
import 'package:widgets/email.dart';

final ApplicationContext _context = new ApplicationContext.fromStartupInfo();

void _log(String msg) {
  print('[email_nav] $msg');
}

/// An implementation of the [Module] interface.
class ModuleImpl extends Module {
  final ModuleBinding _binding = new ModuleBinding();

  /// Bind an [InterfaceRequest] for a [Module] interface to this object.
  void bind(InterfaceRequest<Module> request) {
    _binding.bind(this, request);
  }

  /// Implementation of the Initialize(Story story, Link link) method.
  @override
  void initialize(
    InterfaceHandle<Story> storyHandle,
    InterfaceHandle<Link> linkHandle,
    InterfaceHandle<ServiceProvider> incomingServicesHandle,
    InterfaceRequest<ServiceProvider> outgoingServices,
  ) {
    _log('ModuleImpl::initialize call');
  }

  @override
  void stop(void callback()) {
    _log('ModuleImpl::stop call');

    // Do some clean up here.

    // Invoke the callback to signal that the clean-up process is done.
    callback();
  }
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
  List<FolderGroup> _folderGroups;
  Folder _selectFolder;
  User _user;

  @override
  void initState() {
    _folderGroups = <FolderGroup>[
      new FolderGroup(
        folders: <Folder>[
          new Folder(
            id: 'INBOX',
            name: 'Inbox',
            unread: 10,
            type: 'system',
          ),
          new Folder(
            id: 'STARRED',
            name: 'Starred',
            unread: 5,
            type: 'system',
          ),
          new Folder(
            id: 'DRAFT',
            name: 'Starred',
            unread: 0,
            type: 'system',
          ),
          new Folder(
            id: 'TRASH',
            name: 'Trash',
            unread: 0,
            type: 'system',
          ),
        ],
      ),
      new FolderGroup(
        name: 'Work Folders',
        folders: <Folder>[
          new Folder(
            id: 'TODO',
            name: 'Todo',
            unread: 2,
            type: 'user',
          ),
          new Folder(
            id: 'COMPLETED',
            name: 'Completed',
            unread: 2,
            type: 'user',
          ),
          new Folder(
            id: 'JIRA',
            name: 'Jira',
            unread: 0,
            type: 'user',
          ),
          new Folder(
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

  void _handleSelectFolder(Folder folder) {
    setState(() {
      _selectFolder = folder;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new InboxMenu(
        folderGroups: _folderGroups,
        onSelectFolder: _handleSelectFolder,
        selectedFolder: _selectFolder,
        user: _user,
      ),
    );
  }
}

/// Main entry point to the email folder list module.
void main() {
  _log('Email nav module started with context: $_context');

  /// Add [ModuleImpl] to this application's outgoing ServiceProvider.
  _context.outgoingServices.addServiceForName(
    (InterfaceRequest<Module> request) {
      _log('Received binding request for Module');
      new ModuleImpl().bind(request);
    },
    Module.serviceName,
  );

  runApp(new EmailMenuScreen());
}
