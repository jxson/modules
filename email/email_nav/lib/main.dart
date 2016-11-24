// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modular.lib.app.dart/app.dart';
import 'package:apps.modular.services.application/service_provider.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modular.services.story/module.fidl.dart';
import 'package:apps.modular.services.story/story.fidl.dart';
import 'package:apps.modules.email.email_service/threads.fidl.dart' as es;
import 'package:flutter/material.dart';
import 'package:lib.fidl.dart/bindings.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';
import 'package:widgets/email.dart';

final ApplicationContext _context = new ApplicationContext.fromStartupInfo();

ModuleImpl _module;

void _log(String msg) {
  print('[email_nav] $msg');
}

/// An implementation of the [Module] interface.
class ModuleImpl extends Module {
  final ModuleBinding _binding = new ModuleBinding();

  /// [ServiceProvider] given from the parent module.
  final ServiceProviderProxy incomingServices = new ServiceProviderProxy();

  /// [Threads] service obtained from the incoming [ServiceProvider].
  final es.ThreadsProxy threadsService = new es.ThreadsProxy();

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

    // This `serviceProvider` is originally from the `email_service`, which can
    // serve the `Threads` interface. Use `connectToService` function to get the
    // actual `Threads` interface.
    incomingServices.ctrl.bind(incomingServicesHandle);
    connectToService(incomingServices, threadsService.ctrl);

    // Call the function defined in threads.fidl, and print the received value.
    threadsService.inbox(0, (List<es.Thread> threads) {
      _log('Received threads from the email service');
      threads.forEach((es.Thread t) {
        _log('id: ${t.id}');
      });
    });
  }

  @override
  void stop(void callback()) {
    _log('ModuleImpl::stop call');
    threadsService.ctrl.close();
    incomingServices.ctrl.close();
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

/// Main entry point to the email folder list module.
void main() {
  _log('Email nav module started with context: $_context');

  /// Add [ModuleImpl] to this application's outgoing ServiceProvider.
  _context.outgoingServices.addServiceForName(
    (InterfaceRequest<Module> request) {
      _log('Received binding request for Module');
      if (_module != null) {
        _log('Module interface can only be provided once. Rejecting request.');
        request.channel.close();
        return;
      }
      _module = new ModuleImpl()..bind(request);
    },
    Module.serviceName,
  );

  runApp(new EmailMenuScreen());
}
