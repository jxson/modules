// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modular.lib.app.dart/app.dart';
import 'package:apps.modular.services.application/service_provider.fidl.dart';
import 'package:apps.modular.services.document_store/document.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modular.services.story/module.fidl.dart';
import 'package:apps.modular.services.story/story.fidl.dart';
import 'package:flutter/widgets.dart';
import 'package:lib.fidl.dart/bindings.dart';

final ApplicationContext _context = new ApplicationContext.fromStartupInfo();

final ModuleBinding _moduleBinding = new ModuleBinding();

/// Main entry point to the color module.
void main() {
  _log('Color module started with context: $_context');

  final GlobalKey<_ColorWidgetState> colorWidgetKey =
      new GlobalKey<_ColorWidgetState>();

  /// Add _ModuleImpl to this application's outgoing ServiceProvider.
  _context.outgoingServices.addServiceForName(
    (InterfaceRequest<Module> request) {
      _moduleBinding.bind(
        new _ModuleImpl(
          (Map<String, Document> documents) {
            _log('Documents: $documents');
            documents.values
                .where(
                  (Document document) => document.properties['color'] != null,
                )
                .map((Document document) => document.properties['color'])
                .forEach(
                  (String colorValue) =>
                      colorWidgetKey.currentState.color = new Color(
                        int.parse(colorValue),
                      ),
                );
          },
        ),
        request,
      );
    },
    Module.serviceName,
  );

  runApp(new _ColorWidget(key: colorWidgetKey));
}

void _log(String msg) {
  print('[Color Module] $msg');
}

typedef void _OnDocuments(Map<String, Document> documents);

class _LinkWatcherImpl extends LinkWatcher {
  final _OnDocuments _onDocuments;

  _LinkWatcherImpl(this._onDocuments);

  @override
  void notify(Map<String, Document> documents) {
    _onDocuments?.call(documents);
  }
}

/// An implementation of the [Module] interface.
class _ModuleImpl extends Module {
  /// [Link] service provided by the framework.
  final LinkProxy _link = new LinkProxy();

  final LinkWatcherBinding _linkWatcherBinding = new LinkWatcherBinding();

  final _OnDocuments _onDocuments;

  _ModuleImpl(this._onDocuments);

  /// Implementation of the Initialize(Story story, Link link) method.
  @override
  void initialize(
    InterfaceHandle<Story> storyHandle,
    InterfaceHandle<Link> linkHandle,
    InterfaceHandle<ServiceProvider> incomingServices,
    InterfaceRequest<ServiceProvider> outgoingServices,
  ) {
    _log('ModuleImpl::initialize call');
    _link.ctrl.bind(linkHandle);
    _link.watch(_linkWatcherBinding.wrap(new _LinkWatcherImpl(_onDocuments)));
  }

  @override
  void stop(void callback()) {
    _log('ModuleImpl::stop call');

    _link.ctrl.close();
    _linkWatcherBinding.close();

    // Invoke the callback to signal that the clean-up process is done.
    callback();
  }
}

class _ColorWidget extends StatefulWidget {
  _ColorWidget({Key key}) : super(key: key);

  @override
  _ColorWidgetState createState() => new _ColorWidgetState();
}

class _ColorWidgetState extends State<_ColorWidget> {
  Color _color = new Color(0x00000000);

  set color(Color color) {
    setState(() {
      _color = color;
    });
  }

  @override
  Widget build(BuildContext context) => new Container(
        decoration: new BoxDecoration(
          backgroundColor: _color,
        ),
      );
}
