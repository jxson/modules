// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'src/resolver_capability.dart';

export 'src/resolver_capability.dart';

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
  BoxConstraints constraints;
  List<ResolverCapability> capabilities;
  Widget fallback;
  String name;
  Map<Symbol, dynamic> arguments;

  Resolver({
    Key key,
    this.constraints,
    this.capabilities,
    this.fallback,
    this.arguments,
  }) : super(key: key) {
  }

  /// Resolves a ModuleWidgetBuilder given the module data payload and capabilities
  Resolver.resolve({
    BoxConstraints constraints,
    List<ResolverCapability> capabilities,
    Widget fallback,
    String name,
    Map<Symbol, dynamic> arguments,
  });

  @override
  _ResolverState createState() => new _ResolverState();
}


class _ResolverState extends State<Resolver> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
    );
  }
}
