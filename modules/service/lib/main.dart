// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:application.lib.app.dart/app.dart';
import 'package:application.services/service_provider.fidl.dart';
import 'package:apps.email.services/email_service.fidl.dart' as es;
import 'package:apps.modular.services.module/module.fidl.dart';
import 'package:apps.modular.services.module/module_context.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:flutter/material.dart';
import 'package:lib.fidl.dart/bindings.dart';

import 'src/email_impl.dart';

final ApplicationContext _context = new ApplicationContext.fromStartupInfo();

ModuleImpl _module;

void _log(String msg) {
  print('[email_service] $msg');
}

/// An implementation of the [Module] interface.
class ModuleImpl extends Module {
  final ModuleBinding _binding = new ModuleBinding();

  /// A [ServiceProvider] implementation to be used as the outgoing services.
  final ServiceProviderImpl outgoingServices = new ServiceProviderImpl();

  final EmailServiceImpl _emailServiceImpl = new EmailServiceImpl();

  /// Bind an [InterfaceRequest] for a [Module] interface to this object.
  void bind(InterfaceRequest<Module> request) {
    _binding.bind(this, request);
  }

  /// Implementation of the Initialize(Story story, Link link) method.
  @override
  void initialize(
    InterfaceHandle<ModuleContext> moduleContextHandle,
    InterfaceHandle<Link> linkHandle,
    InterfaceHandle<ServiceProvider> incomingServices,
    InterfaceRequest<ServiceProvider> outgoingServicesRequest,
  ) {
    _log('ModuleImpl::initialize call');

    // Register the service provider which can serve the `Threads` service.
    outgoingServices
      ..addServiceForName(
        (InterfaceRequest<es.EmailService> request) {
          _log('Received binding request for Threads');
          _emailServiceImpl.bind(request);
        },
        es.EmailService.serviceName,
      )
      ..bind(outgoingServicesRequest);
  }

  @override
  void stop(void callback()) {
    _log('ModuleImpl::stop call');
    _emailServiceImpl.close();
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
      if (_module != null) {
        _log('Module interface can only be provided once. Rejecting request.');
        request.channel.close();
        return;
      }
      _module = new ModuleImpl()..bind(request);
    },
    Module.serviceName,
  );

  runApp(new MaterialApp(
    title: 'Email Service',
    home: new Text('This should never be seen.'),
  ));
}
