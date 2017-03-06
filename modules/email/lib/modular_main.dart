// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:application.lib.app.dart/app.dart';
import 'package:application.services/service_provider.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modular.services.module/module.fidl.dart';
import 'package:apps.modular.services.module/module_context.fidl.dart';
import 'package:flutter/widgets.dart';
import 'package:lib.fidl.dart/bindings.dart';

import 'src/app.dart';

final ApplicationContext _appContext = new ApplicationContext.fromStartupInfo();

ModuleImpl _module;

/// An implementation of the [Module] interface.
class ModuleImpl extends Module {
  final ModuleBinding _binding = new ModuleBinding();

  /// Bind an [InterfaceRequest] for a [Module] interface to this object.
  void bind(InterfaceRequest<Module> request) {
    _binding.bind(this, request);
  }

  @override
  void initialize(
      InterfaceHandle<ModuleContext> moduleContextHandle,
      InterfaceHandle<Link> linkHandle,
      InterfaceHandle<ServiceProvider> incomingServices,
      InterfaceRequest<ServiceProvider> outgoingServices) {}

  @override
  void stop(void callback()) {
    callback();
  }
}

/// Entry point for this module.
void main() {
  _appContext.outgoingServices.addServiceForName(
    (InterfaceRequest<Module> request) {
      if (_module == null) {
        _module = new ModuleImpl();
      }

      _module.bind(request);
    },
    Module.serviceName,
  );

  runApp(new App());
}
