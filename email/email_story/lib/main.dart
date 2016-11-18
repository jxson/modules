// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:apps.modular.lib.app.dart/app.dart';
import 'package:apps.modular.services.application/service_provider.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modular.services.story/module.fidl.dart';
import 'package:apps.modular.services.story/module_controller.fidl.dart';
import 'package:apps.modular.services.story/story.fidl.dart';
import 'package:apps.mozart.lib.flutter/child_view.dart';
import 'package:apps.mozart.services.views/view_manager.fidl.dart';
import 'package:apps.mozart.services.views/view_provider.fidl.dart';
import 'package:apps.mozart.services.views/view_token.fidl.dart';
import 'package:flutter/material.dart';
import 'package:lib.fidl.dart/bindings.dart';

final ApplicationContext _context = new ApplicationContext.fromStartupInfo();
ChildViewConnection _connFolderList;

void _log(String msg) {
  print('[Email Quarterback Module] $msg');
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
    InterfaceHandle<ServiceProvider> incoming_services,
    InterfaceRequest<ServiceProvider> outgoing_services,
  ) {
    _log('ModuleImpl::initialize call');

    StoryProxy story = new StoryProxy();
    story.ctrl.bind(storyHandle);

    LinkProxy link = new LinkProxy();
    // TODO(SO-133): Stop this from crashing on Fuchsia
    link.ctrl.bind(linkHandle);

    LinkProxy link2 = new LinkProxy();
    LinkProxy link3 = new LinkProxy();
    link.dup(link2.ctrl.request());
    link.dup(link3.ctrl.request());

    ModuleControllerProxy moduleController = new ModuleControllerProxy();
    ViewOwnerProxy viewOwner = new ViewOwnerProxy();

    story.startModule(
      'file:///system/apps/email_folder_list',
      link2.ctrl.unbind(),
      null,
      null,
      moduleController.ctrl.request(),
      viewOwner.ctrl.request(),
    );

    ModuleControllerProxy serviceModuleController = new ModuleControllerProxy();
    ViewOwnerProxy serviceViewOwner = new ViewOwnerProxy();

    _log('starting email_service');
    story.startModule(
      'file:///system/apps/email_service',
      link3.ctrl.unbind(),
      null,
      null,
      serviceModuleController.ctrl.request(),
      serviceViewOwner.ctrl.request(),
    );

    _log('started email_service');

    _connFolderList = new ChildViewConnection(viewOwner.ctrl.unbind());
    homeKey.currentState?.setState(() {});
  }

  @override
  void stop(void callback()) {
    _log('ModuleImpl::stop call');

    // Do some clean up here.

    // Invoke the callback to signal that the clean-up process is done.
    callback();
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  @override
  HomeScreenState createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[
      new Text('I am the email quarterback module!'),
    ];

    if (_connFolderList != null) {
      children.add(new Flexible(
        flex: 1,
        child: new ChildView(connection: _connFolderList),
      ));
    }

    return new Column(children: children);
  }
}

GlobalKey<HomeScreenState> homeKey = new GlobalKey<HomeScreenState>();

/// Main entry point to the quarterback module.
void main() {
  _log('Email quarterback module started with context: $_context');

  /// Add [ModuleImpl] to this application's outgoing ServiceProvider.
  _context.outgoingServices.addServiceForName(
    (request) {
      _log('Received binding request for Module');
      new ModuleImpl().bind(request);
    },
    Module.serviceName,
  );

  runApp(new MaterialApp(
    title: 'Email Quarterback',
    home: new HomeScreen(key: homeKey),
  ));
}
