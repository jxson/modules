// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modular.lib.app.dart/app.dart';
import 'package:apps.modular.services.application/service_provider.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modular.services.story/module.fidl.dart';
import 'package:apps.modular.services.story/story.fidl.dart';
import 'package:apps.modules.email.email_session/email_session.fidl.dart' as es;
import 'package:lib.fidl.dart/bindings.dart';

import 'email_session_link_store.dart';

/// The callback when the module is requested and and created
typedef void EmailSessionModuleCreated(EmailSessionModule module);

/// The initiailzation function for EmailSessionModules
typedef void EmailSessionModuleInit(
    es.EmailSession es, EmailSessionLinkStore store);

/// The stop function for EmailSessionModules
typedef void EmailSessionModuleStop(void callback());

/// Convenience method to register the Module service with the environment.
void addEmailSessionModule(
    ApplicationContext context,
    String name,
    EmailSessionModuleCreated created,
    EmailSessionModuleInit init,
    EmailSessionModuleStop stop) {
  EmailSessionModule module;
  context.outgoingServices.addServiceForName(
    (InterfaceRequest<Module> request) {
      dynamic _log = (String msg) {
        print('[$name] $msg');
      };
      _log('Received binding request for Module');
      if (module != null) {
        _log('Module interface can only be provided once. Rejecting request.');
        request.channel.close();
        return;
      }
      module = new EmailSessionModule(name, init, stop)..bind(request);
      created(module);
    },
    Module.serviceName,
  );
}

///  A [Module] that encapsulates binding to EmailSession service and link
class EmailSessionModule extends Module {
  /// The name of this module.
  final String name;

  final EmailSessionModuleInit _initCallback;

  final EmailSessionModuleStop _stopCallback;

  final ModuleBinding _binding = new ModuleBinding();

  /// [ServiceProvider] given from the parent module.
  final ServiceProviderProxy _incomingServices = new ServiceProviderProxy();

  /// [EmailSession] service obtained from the incoming [ServiceProvider].
  final es.EmailSessionProxy _emailSessionService = new es.EmailSessionProxy();

  /// [Link] for watching the[EmailSession] state.
  final LinkProxy _emailSessionLinkProxy = new LinkProxy();

  /// Construct
  /// Name of this module, and the initialization function that will be called back.
  EmailSessionModule(this.name, this._initCallback, this._stopCallback);

  /// Bind an [InterfaceRequest] for a [Module] interface to this object.
  void bind(InterfaceRequest<Module> request) {
    _binding.bind(this, request);
  }

  void _log(String msg) {
    print('[$this.name] $msg');
  }

  /// Implementation of the Initialize(Story story, Link link) method.
  @override
  void initialize(
    InterfaceHandle<Story> storyHandle,
    InterfaceHandle<Link> linkHandle,
    InterfaceHandle<ServiceProvider> incomingServicesHandle,
    InterfaceRequest<ServiceProvider> outgoingServices,
  ) {
    _log('EmailSessionModuleInit::initialize call');
    _incomingServices.ctrl.bind(incomingServicesHandle);
    connectToService(_incomingServices, _emailSessionService.ctrl);
    _emailSessionLinkProxy.ctrl.bind(linkHandle);
    _initCallback(_emailSessionService,
        new EmailSessionLinkStore(_emailSessionLinkProxy));
  }

  @override
  void stop(void callback()) {
    _log('EmailSessionModuleInit::stop call');
    _stopCallback(() {
      _emailSessionLinkProxy.ctrl.unbind();
      _emailSessionService.ctrl.close();
      _incomingServices.ctrl.close();
      callback();
    });
  }
}
