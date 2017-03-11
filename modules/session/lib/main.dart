// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:application.lib.app.dart/app.dart';
import 'package:application.services/service_provider.fidl.dart';
import 'package:apps.email.services/email_session.fidl.dart' as es;
import 'package:apps.modular.services.component/component_context.fidl.dart';
import 'package:apps.modular.services.module/module.fidl.dart';
import 'package:apps.modular.services.module/module_context.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
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

  /// A [ServiceProvider] implementation for exposing [EmailSession] service.
  final ServiceProviderImpl _serviceProviderImpl = new ServiceProviderImpl();

  /// [Link] for watching the[EmailSession] state.
  final LinkProxy emailSessionLinkProxy = new LinkProxy();
  final ModuleContextProxy _emailModuleContextProxy = new ModuleContextProxy();

  /// A [EmailSessionImpl] instance.
  EmailSessionImpl _emailSessionImpl;

  /// Bind an [InterfaceRequest] for a [Module] interface to this object.
  void bind(InterfaceRequest<Module> request) {
    _binding.bind(this, request);
  }

  /// Implementation of the Initialize(ModuleContext ctx, Link link) method.
  @override
  void initialize(
    InterfaceHandle<ModuleContext> moduleContextHandle,
    InterfaceHandle<Link> linkHandle,
    InterfaceHandle<ServiceProvider> incomingServices,
    InterfaceRequest<ServiceProvider> outgoingServices,
  ) {
    _log('ModuleImpl::initialize call');
    _emailModuleContextProxy.ctrl.bind(moduleContextHandle);
    emailSessionLinkProxy.ctrl.bind(linkHandle);

    // TODO(alangardner): Temporarily start with mock data
    EmailSessionDoc sessionState = new EmailSessionDoc.withMockData();

    /// Setup [ComponentContextProxy]
    ComponentContextProxy componentContextProxy = new ComponentContextProxy();
    _emailModuleContextProxy
        .getComponentContext(componentContextProxy.ctrl.request());

    /// Get [storyId] and [MessageQueue], and initialize [EmailSessionImpl]
    _emailModuleContextProxy.getStoryId((String storyId) {
      _emailSessionImpl = new EmailSessionImpl(
          storyId, emailSessionLinkProxy, sessionState, componentContextProxy)
        ..initialize();

      _serviceProviderImpl.addServiceForName(
        (InterfaceRequest<es.EmailSession> request) {
          _log('Received binding request for EmailSession');
          _emailSessionImpl.bind(request);
        },
        es.EmailSession.serviceName,
      );
      _serviceProviderImpl.bind(outgoingServices);
    });
  }

  @override
  void stop(void callback()) {
    _log('ModuleImpl::stop call');
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
