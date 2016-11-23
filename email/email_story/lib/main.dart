// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modular.lib.app.dart/app.dart';
import 'package:apps.modular.services.application/service_provider.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modular.services.story/module.fidl.dart';
import 'package:apps.modular.services.story/module_controller.fidl.dart';
import 'package:apps.modular.services.story/story.fidl.dart';
import 'package:apps.mozart.lib.flutter/child_view.dart';
import 'package:apps.mozart.services.views/view_token.fidl.dart';
import 'package:flutter/material.dart';
import 'package:lib.fidl.dart/bindings.dart';
import 'package:lib.fidl.dart/core.dart';

final ApplicationContext _context = new ApplicationContext.fromStartupInfo();

final String _kEmailServiceUrl = 'file:///system/apps/email_service';
final String _kEmailNavUrl = 'file:///system/apps/email_nav';
final String _kEmailListUrl = 'file:///system/apps/email_list';
final String _kEmailThreadUrl = 'file:///system/apps/email_thread';

final GlobalKey<HomeScreenState> _kHomeKey = new GlobalKey<HomeScreenState>();

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

  @override
  void connectToService(String serviceName, Channel channel) {
    serviceProvider.connectToService(serviceName, channel);
  }
}

/// An implementation of the [Module] interface.
class ModuleImpl extends Module {
  final ModuleBinding _binding = new ModuleBinding();

  /// [Story] service provided by the framework.
  final StoryProxy story = new StoryProxy();

  /// [Link] service provided by the framework.
  final LinkProxy link = new LinkProxy();

  /// [ServiceProvider] obtained
  final ServiceProviderProxy emailServices = new ServiceProviderProxy();

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

    story.ctrl.bind(storyHandle);
    link.ctrl.bind(linkHandle);

    // Obtain the email service provider from the email_service module.
    startModule(
      url: _kEmailServiceUrl,
      incomingServices: emailServices.ctrl.request(),
    );

    InterfaceHandle<ViewOwner> navViewOwner = startModule(
      url: _kEmailNavUrl,
      outgoingServices: new ServiceProviderWrapper(emailServices).getHandle(),
    );
    _connNav = new ChildViewConnection(navViewOwner);
    updateUI();

    InterfaceHandle<ViewOwner> listViewOwner = startModule(
      url: _kEmailListUrl,
      outgoingServices: new ServiceProviderWrapper(emailServices).getHandle(),
    );
    _connList = new ChildViewConnection(listViewOwner);
    updateUI();

    InterfaceHandle<ViewOwner> threadViewOwner = startModule(
      url: _kEmailThreadUrl,
      outgoingServices: new ServiceProviderWrapper(emailServices).getHandle(),
    );
    _connThread = new ChildViewConnection(threadViewOwner);
    updateUI();
  }

  @override
  void stop(void callback()) {
    _log('ModuleImpl::stop call');
    story.ctrl.close();
    link.ctrl.close();
    emailServices.ctrl.close();
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
    ViewOwnerProxy viewOwner = new ViewOwnerProxy();
    ModuleControllerProxy moduleController = new ModuleControllerProxy();

    _log('Starting sub-module: $url');
    story.startModule(
      url,
      duplicateLink(link),
      outgoingServices,
      incomingServices,
      moduleController.ctrl.request(),
      viewOwner.ctrl.request(),
    );
    _log('Started sub-module: $url');

    // Close this to prevent leaks.
    moduleController.ctrl.close();

    return viewOwner.ctrl.unbind();
  }

  /// Obtains a duplicated [InterfaceHandle] for the given [Link] object.
  InterfaceHandle<Link> duplicateLink(Link link) {
    LinkProxy linkProxy = new LinkProxy();
    link.dup(linkProxy.ctrl.request());
    return linkProxy.ctrl.unbind();
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
    Widget nav = new Flexible(
      flex: 2,
      child: _connNav != null
          ? new ChildView(connection: _connNav)
          : new Container(),
    );

    Widget list = new Flexible(
      flex: 3,
      child: new Container(
        margin: new EdgeInsets.symmetric(horizontal: 4.0),
        child: new Material(
          elevation: 2,
          child: _connList != null
              ? new ChildView(connection: _connList)
              : new Container(),
        ),
      ),
    );

    Widget thread = new Flexible(
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
      new ModuleImpl().bind(request);
    },
    Module.serviceName,
  );

  runApp(new HomeScreen(key: _kHomeKey));
}
