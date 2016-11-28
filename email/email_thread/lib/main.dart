// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:apps.modular.lib.app.dart/app.dart';
import 'package:apps.modular.services.document_store/document.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modular.services.story/module_controller.fidl.dart';
import 'package:apps.modules.email.email_session/email_session.fidl.dart' as es;
import 'package:apps.mozart.lib.flutter/child_view.dart';
import 'package:email_session_client/client.dart';
import 'package:email_session_store/email_session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:lib.fidl.dart/bindings.dart';
import 'package:widgets/email.dart';

const String _moduleName = 'email_thread';
final ApplicationContext _context = new ApplicationContext.fromStartupInfo();
EmailSessionModule _module;

void _log(String msg) {
  print('[$_moduleName] $msg');
}

void _created(EmailSessionModule module) {
  _module = module;
}

void _initialize(es.EmailSession service, EmailSessionLinkStore store) {
  // HACK: Global reference must be set before store is accessed by widgets.
  kEmailSessionStoreToken = new StoreToken(store);

  _addEmbeddedChildBuilders();

  runApp(new MaterialApp(
    title: 'Email Thread Module',
    home: new EmailThreadScreen(),
    theme: new ThemeData(primarySwatch: Colors.blue),
    debugShowCheckedModeBanner: false,
  ));
}

void _stop(void callback()) {
  callback();
}

/// Main entry point to the email thread module.
void main() {
  _log('Email thread module started with context: $_context');
  addEmailSessionModule(_context, _moduleName, _created, _initialize, _stop);
}

/// Adds all the [EmbeddedChildBuilder]s that this module supports.
void _addEmbeddedChildBuilders() {
  // USPS Tracking.
  kEmbeddedChildProvider.addEmbeddedChildBuilder(
    'usps-shipping',
    (dynamic args) {
      // Initialize the sub-module.
      const String kUSPSModuleUrl = 'file:///system/apps/usps';
      const String kUspsDocId = 'usps-doc';
      const String kUspsTrackingKey = 'usps-tracking-key';

      // Create a new link, add necessary data to it, and create a duplicate of
      // it to be passed to the sub-module.
      LinkProxy link = new LinkProxy();
      _module.story.createLink('usps', link.ctrl.request());
      link.addDocuments(<String, Document>{
        kUspsDocId: new Document.init(kUspsDocId, <String, Value>{
          // We assume that the 'args' contains the tracking number as String.
          kUspsTrackingKey: new Value()..stringValue = args,
        }),
      });

      InterfacePair<Link> dupLink = new InterfacePair<Link>();
      link.dup(dupLink.passRequest());

      ModuleControllerProxy moduleController = new ModuleControllerProxy();
      InterfacePair<ViewOwner> viewOwnerPair = new InterfacePair<ViewOwner>();

      _module.story.startModule(
        kUSPSModuleUrl,
        dupLink.passHandle(),
        null,
        null,
        moduleController.ctrl.request(),
        viewOwnerPair.passRequest(),
      );

      InterfaceHandle<ViewOwner> viewOwner = viewOwnerPair.passHandle();
      ChildViewConnection conn = new ChildViewConnection(viewOwner);

      return new EmbeddedChild(
        widgetBuilder: (_) => new ChildView(connection: conn),
        disposer: () {
          moduleController.stop(() {
            link.ctrl.close();
            viewOwner.close();
            // NOTE(youngseokyoon): Not sure if it is safe to close the module
            // controller within a callback passed to module controller, so do
            // it in the next idle cycle.
            scheduleMicrotask(() {
              moduleController.ctrl.close();
            });
          });
        },
      );
    },
  );
}
