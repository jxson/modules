// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:application.lib.app.dart/app.dart';
import 'package:application.services/service_provider.fidl.dart';
import 'package:apps.modular.services.module/module.fidl.dart';
import 'package:apps.modular.services.module/module_context.fidl.dart';
import 'package:apps.modular.services.module/module_controller.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.mozart.lib.flutter/child_view.dart';
import 'package:apps.mozart.services.views/view_token.fidl.dart';
import 'package:flutter/material.dart';
import 'package:lib.fidl.dart/bindings.dart';
import 'package:lib.fidl.dart/core.dart';

final ApplicationContext _context = new ApplicationContext.fromStartupInfo();

final String _kEmailSessionUrl = 'file:///system/apps/email_session';
final String _kEmailNavUrl = 'file:///system/apps/email_nav';
final String _kEmailListUrl = 'file:///system/apps/email_thread_list';
final String _kEmailThreadUrl = 'file:///system/apps/email_thread';

final GlobalKey<HomeScreenState> _kHomeKey = new GlobalKey<HomeScreenState>();

ModuleImpl _module;

ChildViewConnection _connNav;
ChildViewConnection _connList;
ChildViewConnection _connThread;

void _log(String msg) {
  print('[email_story] $msg');
}

/// A wrapper class for duplicating ServiceProvider
class ServiceProviderWrapper extends ServiceProvider {
  final ServiceProviderBinding _binding = new ServiceProviderBinding();

  /// The original [ServiceProvider] instance that this class wraps.
  final ServiceProvider serviceProvider;

  /// Creates a new [ServiceProviderWrapper] with the given [ServiceProvider].
  ServiceProviderWrapper(this.serviceProvider);

  /// Gets the [InterfaceHandle] for this [ServiceProvider] wrapper.
  ///
  /// The returned handle should only be used once.
  InterfaceHandle<ServiceProvider> getHandle() => _binding.wrap(this);

  /// Closes the binding.
  void close() => _binding.close();

  @override
  void connectToService(String serviceName, Channel channel) {
    serviceProvider.connectToService(serviceName, channel);
  }
}

/// An implementation of the [Module] interface.
class ModuleImpl extends Module {
  final ModuleBinding _binding = new ModuleBinding();

  /// [ModuleContext] service provided by the framework.
  final ModuleContextProxy moduleContext = new ModuleContextProxy();

  /// [Link] service provided by the framework.
  final LinkProxy link = new LinkProxy();

  /// [ServiceProviderProxy] between email session and UI modules.
  final ServiceProviderProxy emailSessionProvider = new ServiceProviderProxy();

  /// A list used for holding references to the [ServiceProviderWrapper]
  /// objects for the lifetime of this module.
  final List<ServiceProviderWrapper> serviceProviders =
      <ServiceProviderWrapper>[];

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
    InterfaceRequest<ServiceProvider> outgoingServices,
  ) {
    _log('ModuleImpl::initialize call');

    moduleContext.ctrl.bind(moduleContextHandle);
    link.ctrl.bind(linkHandle);

    startModule(
      url: _kEmailSessionUrl,
      incomingServices: emailSessionProvider.ctrl.request(),
    );

    InterfaceHandle<ViewOwner> navViewOwner = startModule(
      url: _kEmailNavUrl,
      outgoingServices: duplicateServiceProvider(emailSessionProvider),
    );
    _connNav = new ChildViewConnection(navViewOwner);
    updateUI();

    InterfaceHandle<ViewOwner> listViewOwner = startModule(
      url: _kEmailListUrl,
      outgoingServices: duplicateServiceProvider(emailSessionProvider),
    );
    _connList = new ChildViewConnection(listViewOwner);
    updateUI();

    InterfaceHandle<ViewOwner> threadViewOwner = startModule(
      url: _kEmailThreadUrl,
      outgoingServices: duplicateServiceProvider(emailSessionProvider),
    );
    _connThread = new ChildViewConnection(threadViewOwner);
    updateUI();
  }

  @override
  void stop(void callback()) {
    _log('ModuleImpl::stop call');
    moduleContext.ctrl.close();
    link.ctrl.close();
    emailSessionProvider.ctrl.close();
    serviceProviders.forEach((ServiceProviderWrapper s) => s.close());
    callback();
  }

  /// Updates the UI by calling setState on the [HomeScreenState] object.
  void updateUI() {
    _kHomeKey.currentState?.updateUI();
  }

  /// Start a module and return its [ViewOwner] handle.
  InterfaceHandle<ViewOwner> startModule({
    String url,
    InterfaceHandle<ServiceProvider> outgoingServices,
    InterfaceRequest<ServiceProvider> incomingServices,
  }) {
    InterfacePair<ViewOwner> viewOwnerPair = new InterfacePair<ViewOwner>();
    InterfacePair<ModuleController> moduleControllerPair =
        new InterfacePair<ModuleController>();

    _log('Starting sub-module: $url');
    moduleContext.startModule(
      url,
      duplicateLink(),
      outgoingServices,
      incomingServices,
      moduleControllerPair.passRequest(),
      viewOwnerPair.passRequest(),
    );
    _log('Started sub-module: $url');

    return viewOwnerPair.passHandle();
  }

  /// Obtains a duplicated [InterfaceHandle] for the given [Link] object.
  InterfaceHandle<Link> duplicateLink() {
    InterfacePair<Link> linkPair = new InterfacePair<Link>();
    link.dup(linkPair.passRequest());
    return linkPair.passHandle();
  }

  /// Duplicates a [ServiceProvider] and returns its handle.
  InterfaceHandle<ServiceProvider> duplicateServiceProvider(ServiceProvider s) {
    ServiceProviderWrapper dup = new ServiceProviderWrapper(s);
    serviceProviders.add(dup);
    return dup.getHandle();
  }
}

/// The top level [StatefulWidget].
class HomeScreen extends StatefulWidget {
  /// Creates a new [HomeScreen].
  HomeScreen({Key key}) : super(key: key);

  @override
  HomeScreenState createState() => new HomeScreenState();
}

/// The [State] class for the [HomeScreen].
class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    Widget nav = new Expanded(
      flex: 2,
      child: new Column(
        children: <Widget>[
          new Expanded(
            flex: 1,
            child: _connNav != null
                ? new ChildView(connection: _connNav)
                : new Container(),
          ),
          new Container(
            padding: new EdgeInsets.all(10.0),
            child: new Align(
              alignment: FractionalOffset.bottomLeft,
            ),
          ),
        ],
      ),
    );

    Widget list = new Expanded(
      flex: 3,
      child: new Container(
        padding: new EdgeInsets.symmetric(horizontal: 4.0),
        child: new Material(
          elevation: 2,
          child: _connList != null
              ? new ChildView(connection: _connList)
              : new Container(),
        ),
      ),
    );

    Widget thread = new Expanded(
      flex: 4,
      child: _connThread != null
          ? new ChildView(connection: _connThread)
          : new Container(),
    );

    List<Widget> columns = <Widget>[nav, list, thread];
    return new Material(
      color: Colors.white,
      child: new Row(children: columns),
    );
  }

  /// Convenient method for other entities to call setState to cause UI updates.
  void updateUI() {
    setState(() {});
  }
}

/// Main entry point to the quarterback module.
void main() {
  _log('Email quarterback module started with context: $_context');

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

  runApp(new HomeScreen(key: _kHomeKey));
}
