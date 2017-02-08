// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:application.lib.app.dart/app.dart';
import 'package:application.services/service_provider.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modular.services.story/module.fidl.dart';
import 'package:apps.modular.services.story/story.fidl.dart';
import 'package:apps.modules.email.services/email_session.fidl.dart' as es;
import 'package:flutter/material.dart';
import 'package:lib.fidl.dart/bindings.dart';

import 'src/email_session_doc.dart';
import 'src/email_session_impl.dart';

final ApplicationContext _context = new ApplicationContext.fromStartupInfo();

ModuleImpl _module;

void _log(String msg) {
  print('[email_session] $msg');
}

/// An implementation of the [Module] interface.
class ModuleImpl extends Module {
  final ModuleBinding _binding = new ModuleBinding();

  /// A [ServiceProvider] provided from the parent module.
  final ServiceProviderProxy _incomingServices = new ServiceProviderProxy();

  /// A [ServiceProvider] implementation for exposing [EmailSession] service.
  final ServiceProviderImpl _serviceProviderImpl = new ServiceProviderImpl();

  /// [Link] for watching the[EmailSession] state.
  final LinkProxy emailSessionLinkProxy = new LinkProxy();

  /// A [EmailSessionImpl] instance.
  EmailSessionImpl _emailSessionImpl;

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

    emailSessionLinkProxy.ctrl.bind(linkHandle);

    _incomingServices.ctrl.bind(incomingServices);

    // TODO(alangardner): Temporarily start with mock data
    EmailSessionDoc sessionState = new EmailSessionDoc.withMockData();

    _emailSessionImpl = new EmailSessionImpl(
      emailSessionLinkProxy,
      sessionState,
    )..initialize(_incomingServices);

    _serviceProviderImpl.addServiceForName(
      (InterfaceRequest<es.EmailSession> request) {
        _log('Received binding request for EmailSession');
        _emailSessionImpl.bind(request);
      },
      es.EmailSession.serviceName,
    );
    _serviceProviderImpl.bind(outgoingServices);
  }

  @override
  void stop(void callback()) {
    _log('ModuleImpl::stop call');
    _incomingServices.ctrl.close();
    _emailSessionImpl?.close();
    _serviceProviderImpl.close();
    emailSessionLinkProxy.ctrl.close();
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
    title: 'Email Session Service',
    home: new Text('This should never be seen.'),
  ));
}
