// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modular.lib.app.dart/app.dart';
import 'package:apps.modular.services.application/service_provider.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modular.services.story/module.fidl.dart';
import 'package:apps.modular.services.story/story.fidl.dart';
import 'package:flutter/material.dart';
import 'package:lib.fidl.dart/bindings.dart' hide Message;
import 'package:models/email.dart';
import 'package:widgets/email.dart';

final ApplicationContext _context = new ApplicationContext.fromStartupInfo();

void _log(String msg) {
  print('[Email Thread Module] $msg');
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

    StoryProxy story = new StoryProxy();
    story.ctrl.bind(storyHandle);

    LinkProxy link = new LinkProxy();
    link.ctrl.bind(linkHandle);

    ServiceProviderProxy serviceProvider = new ServiceProviderProxy();
    serviceProvider.ctrl.bind(incomingServicesHandle);
  }

  @override
  void stop(void callback()) {
    _log('ModuleImpl::stop call');

    // Do some clean up here.

    // Invoke the callback to signal that the clean-up process is done.
    callback();
  }
}

/// Temporary widget class for the email thread module.
class EmailThreadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Thread thread = new MockThread();

    return new ThreadView(
      thread: thread,
      messageExpanded: (_) => true,
      onSelectMessage: (Message m) => _log('Message Selected: $m'),
      onForwardMessage: _handleMessageAction,
      onReplyAllMessage: _handleMessageAction,
      onReplyMessage: _handleMessageAction,
      footer: new MessageActionBarFooter(
        message: thread.messages.last,
        onForwardMessage: _handleMessageAction,
        onReplyAllMessage: _handleMessageAction,
        onReplyMessage: _handleMessageAction,
      ),
      header: new ThreadActionBarHeader(
        thread: thread,
        onArchive: _handleThreadAction,
        onMoreActions: _handleThreadAction,
        onDelete: _handleThreadAction,
      ),
    );
  }

  void _handleMessageAction(Message m) {
    _log('handleMessageAction: $m');
  }

  void _handleThreadAction(Thread t) {
    _log('handleThreadAction: $t');
  }
}

/// Main entry point to the email folder list module.
void main() {
  _log('Email thread module started with context: $_context');

  /// Add [ModuleImpl] to this application's outgoing ServiceProvider.
  _context.outgoingServices.addServiceForName(
    (InterfaceRequest<Module> request) {
      _log('Received binding request for Module');
      new ModuleImpl().bind(request);
    },
    Module.serviceName,
  );

  runApp(new MaterialApp(
    title: 'Email Thread Module',
    home: new EmailThreadScreen(),
    theme: new ThemeData(primarySwatch: Colors.blue),
    debugShowCheckedModeBanner: false,
  ));
}
