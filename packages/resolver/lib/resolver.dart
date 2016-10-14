// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:widgets/attachment.dart';

import 'src/resolver_capability.dart';

export 'src/resolver_capability.dart';

enum ResolverStatus {
  LOADING,
  RESOLVED,
  NOT_FOUND,
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
class Resolver extends StatefulWidget {
  final Set<Module> modules = new Set<Module>();

  BoxConstraints constraints;
  Widget fallback;
  String name;
  Map<Symbol, dynamic> arguments;

  Resolver({
    Key key,
    this.constraints,
    this.fallback,
    this.arguments,
  }) : super(key: key);

  Resolver.surface({
    this.constraints,
    this.fallback,
    this.name,
    this.arguments,
  }) {
    modules.add(new Module(
      name: 'examples:attachements:youtube-preview',
      capabilities: <ResolverCapability>[
        ResolverCapability.gestures,
      ],
      render: YoutubeAttachmentPreview.render,
    ));
  }

  @override
  _ResolverState createState() => new _ResolverState();
}

class _ResolverState extends State<Resolver> {
  static final Random _rng = new Random();
  static final int _minDelay = 20;
  static final int _maxDelay = 3 * 1000;

  Size size;
  ResolverStatus status;
  Widget resolved;

  @override
  void initState() {
    super.initState();

    status = ResolverStatus.LOADING;
    size = new Size(
      config.constraints.maxWidth,
      config.constraints.maxHeight,
    );

    _resolve();
  }

  @override
  Widget build(BuildContext context) {
    // There are three possible states that need to be represented:
    // 1. Loading...
    // 2. Module resolved and ready to render...
    // 3. There is no Module available, use the fallback.

    Widget child;

    switch (status) {
      case ResolverStatus.LOADING:
        child = new CircularProgressIndicator();
        break;
      case ResolverStatus.RESOLVED:
        child = resolved;
        break;
      case ResolverStatus.NOT_FOUND:
        child = config.fallback;
        break;
    }

    return new Container(
      width: size.width,
      height: size.height,
      child: child,
    );
  }

  void _resolve() {
    int milliseconds = _rng.nextInt(_maxDelay).clamp(_minDelay, _maxDelay);
    Duration duration = new Duration(milliseconds: milliseconds);
    new Future.delayed(duration, () {
      Module module = config.modules.firstWhere((Module module) {
        // TODO: If there is no name provided use the capabilities or mime to
        // fallback on.
        return module.name == config.name;
      }, orElse: () {
        status = ResolverStatus.NOT_FOUND;
      });

      resolved = Function.apply(module.render, null, config.arguments);
    });
  }
}

class Module {
  String name;
  String mime;
  List<ResolverCapability> capabilities;
  Function render;

  Module({ this.name, this.mime, this.capabilities, this.render });
}
