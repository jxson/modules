// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:models/email.dart';
import 'package:widgets/attachment.dart';

import 'src/resolver_capability.dart';

export 'src/resolver_capability.dart';

typedef void HandleResolverError(Error error);

enum ResolverStatus {
  NEW,
  LOADING,
  RESOLVED,
  NOT_FOUND,
}

class Module {
  String name;
  String mime;
  List<ResolverCapability> capabilities;
  Function render;

  Module({ this.name, this.mime, this.capabilities, this.render });
}

final Set<Module> kModules = new Set<Module>;

kModules.add(new Module(
  name: 'examples:attachement:youtube',
  capabilities: const <ResolverCapability>[
    ResolverCapability.gestures,
  ],
  // render: YoutubeAttachment.render,
);

class Resolver {
  final Set<Module> _modules = new Set<Module>();

  static final Random _rng = new Random();
  static final int _minDelay = 20;
  static final int _maxDelay = 3 * 1000;


  String name;
  // I am not sure that capabilities are useful here since they can't be reinforced. This requirment needs to be tracked through...
  List<ResolverCapability> capabilities;
  Attachment attachment;

  ResolverStatus status = ResolverStatus.NEW;
  Module module;

  Resolver({
    this.name,
    this.capabilities,
    this.attachment,
  });

  WidgetBuilder surface({
    // List<ResolverCapability> capabilities,
    BoxConstraints constraints,
    // Widget fallback,
  }) {
    return (BuildContext context) {
      return new Surface(constraints: constraints);
    };
  }

   Future<Null> load() async {
     int milliseconds = _rng.nextInt(_maxDelay).clamp(_minDelay, _maxDelay);
     Duration duration = new Duration(milliseconds: milliseconds);

     return new Future.delayed(duration, () {
       module = find();
     });
   }

   Module find() {
    return kModules.firstWhere((Module module) {
      // TODO: If there is no name provided use the capabilities or mime to
      // fallback on.
      return module.name == name;
    }, orElse: () {
      status = ResolverStatus.NOT_FOUND;
    });

   }
}

/// Resolves modules based on the given Module Data, Module Capabilities and
/// layout BoxConstraints
///
/// For now the the ModuleResolver has the simple logic of selectin the
/// YoutubeAttachmentPreview if the data is an email attachment, and the
/// attachment itself is a Youtube video.
///
/// TODO (dayang): Add some examples of how the resolver might choose between
/// different modules.
class Surface extends StatefulWidget {
  // final Set<Module> modules = new Set<Module>();

  BoxConstraints constraints;

  Surface({
    Key key,
    this.constraints,
  }) : super(key: key);

  @override
  _SurfaceState createState() => new _SurfaceState();
}

class _SurfaceState extends State<Surface> {
  Size size;
  Resolver resolver;

  @override
  void initState() {
    super.initState();

    size = new Size(
      config.constraints.maxWidth,
      config.constraints.maxHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    // There are three possible states that need to be represented:
    // 1. Loading...
    // 2. Module resolved and ready to render...
    // 3. There is no Module available, use the fallback.

    Widget child;

    switch (resolver.status) {
      case ResolverStatus.LOADING:
        // With progress.
        child = new CircularProgressIndicator();
        break;
      case ResolverStatus.RESOLVED:
        // child = resolved;
        break;
      default:
        // Error here, it's impossible to know what to do in this case.
        break;
    }


    return new Container(
      width: size.width,
      height: size.height,
      child: child,
    );
  }
}
