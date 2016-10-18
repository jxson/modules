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

const int _kMinMSDelay = 20;
const int _kMaxMSDelay = 3 * 1000;

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
  WidgetBuilder builder;

  Module({
    this.name,
    this.mime,
    this.capabilities,
    this.builder,
  });
}

final Map<String, Module> _kModules = <String, Module>{
  'examples:attachement:youtube': new Module(
    name: 'examples:attachement:youtube',
    mime: 'application/x.fx.attachment.youtube',
    capabilities: <ResolverCapability>[
      ResolverCapability.gestures,
    ],
    builder: (BuildContext context) {

    }
  ),
  'examples:attachement:pdf': new Module(
    name: 'examples:attachement:pdf',
    mime: 'application/pdf',
    capabilities: <ResolverCapability>[
      ResolverCapability.gestures,
    ],
    builder: (BuildContext context) {

    }
  ),
  // render: YoutubeAttachment.render,
};

class Resolver {
  static final Random _rng = new Random();

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
    BoxConstraints constraints,
  }) {
    return (BuildContext context) {
      return new Surface(constraints: constraints);
    };
  }

   Future<Null> load() async {
     int milliseconds = _rng.nextInt(_kMaxMSDelay).clamp(_kMinMSDelay, _kMaxMSDelay);
     Duration duration = new Duration(milliseconds: milliseconds);

     return new Future.delayed(duration, () {
       module = find();
       if (module == null) {
         status = ResolverStatus.NOT_FOUND;
       }
     });
   }

   Module find() {
    if (_kModules.containsKey(name)) {
      return _kModules[name];
    }

    return _kModules.values.reduce((Module previous, Module current) {
      if (previous == null) {
        return current;
      }

      // An example of a finder based on mimes for attachements.
      // The same could be done with constraints, etc.
      if (attachment != null && current.mime == attachment.mime) {
        return current;
      }
    });
   }
}

class Surface extends StatefulWidget {
  BoxConstraints constraints;
  Resolver resolver;

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

    resolver = config.resolver;
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
