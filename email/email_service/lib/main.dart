// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show JSON;

import 'package:apps.modular.lib.app.dart/app.dart';
import 'package:apps.modular.services.application/service_provider.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modular.services.story/module.fidl.dart';
import 'package:apps.modular.services.story/story.fidl.dart';
import 'package:config_flutter/config.dart';
import 'package:email_api/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lib.fidl.dart/bindings.dart';

final ApplicationContext _context = new ApplicationContext.fromStartupInfo();

void _log(String msg) {
  print('[email_service] $msg');
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
    InterfaceHandle<ServiceProvider> incomingServices,
    InterfaceRequest<ServiceProvider> outgoingServices,
  ) {
    _log('ModuleImpl::initialize call');
  }

  @override
  void stop(void callback()) {
    _log('ModuleImpl::stop call');
    callback();
  }
}

/// Main entry point.
Future<Null> main() async {
  _log('main started with context: $_context');

  /// Add [ModuleImpl] to this application's outgoing ServiceProvider.
  _context.outgoingServices.addServiceForName(
    (InterfaceRequest<Module> request) {
      _log('Received binding request for Module');
      new ModuleImpl().bind(request);
    },
    Module.serviceName,
  );

  Config config = await Config.read('assets/config.json');

  // Validate configuration for the email_api REST Client.
  if (!config.has('oauth_id') ||
      !config.has('oauth_secret') ||
      !config.has('oauth_token') ||
      !config.has('oauth_token_expiry') ||
      !config.has('oauth_refresh_token')) {
    _log('Warning: The configu file does not have the expected values.');
    _log('To get the correct values, run "make auth" from the apps/modules '
        'repository.');
  } else {
    api.Client client = api.client(
        id: config.get('oauth_id'),
        secret: config.get('oauth_secret'),
        token: config.get('oauth_token'),
        expiry: DateTime.parse(config.get('oauth_token_expiry')),
        refreshToken: config.get('oauth_refresh_token'));
    api.GmailApi gmail = new api.GmailApi(client);
    api.ListThreadsResponse response = await gmail.users.threads
        .list('me', labelIds: <String>['INBOX'], maxResults: 15);
    response.threads.forEach((api.Thread thread) {
      _log('thread: ${thread.id}');
    });
  }

  runApp(new MaterialApp(
    title: 'Email Service',
    home: new Text('This should never be seen.'),
  ));
}
