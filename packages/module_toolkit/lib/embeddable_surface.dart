// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'modular_widget.dart';
import 'module_capability.dart';
import 'module_data.dart';
import 'module_resolver.dart';

/// Represents a embeddable surface that allows a 'parent' module to compose a
/// 'child' module with specific requirements
class EmbeddableSurface extends StatefulWidget {
  /// Size contraints that should be enforced for any child module.
  BoxConstraints boxConstraints;

  /// List of capabilities given to the surface of the child module.
  List<ModuleCapability> capabilities;

  /// Module data for this slot
  ModuleData data;

  /// Fallback module(widget) that will be used if no appropiate module can
  /// be resolved.
  Widget fallbackModule;

  /// Constructor
  EmbeddableSurface({
    @required this.boxConstraints,
    @required this.data,
    this.capabilities: const <ModuleCapability>[],
    this.fallbackModule,
  }) {
    assert(boxConstraints != null);
    assert(data != null);
  }

  @override
  _EmbeddableSurfaceState createState() => new _EmbeddableSurfaceState();
}

class _EmbeddableSurfaceState extends State<EmbeddableSurface> {
  /// The resolved module, if this is null it means that the module hasn't
  /// resolved yet, or no module can be found for the given surface
  ModularWidgetBuilder _resolvedModuleBuilder;

  @override
  void initState() {
    super.initState();
    // Try to find a module that can statisfy the given data, capabilities and
    // size constraints
    ModuleResolver
        .resolve(
      data: config.data,
      capabilities: config.capabilities,
      boxConstraints: config.boxConstraints,
    )
        .then((ModularWidgetBuilder builder) {
      if (builder != null) {
        setState(() {
          _resolvedModuleBuilder = builder;
        });
      }
    });
  }

  /// Figure out the final size of the surface container
  ///
  /// If no module is resolved, then set the surface container at the largest
  /// size possible given the boxContraints passed down by the parent module.
  ///
  /// If a module is resolved, enforce the required boxConstraints by the parent
  /// on the boxContraints of the child module. The surface size will be as
  /// close as possible to the desired constraints of the child module
  /// while strictly adhereing to the requirements of the parent.
  /// See: https://docs.flutter.io/flutter/material/BoxConstraints/enforce.html
  Size _getSurfaceSize() {
    if (_resolvedModuleBuilder == null) {
      return new Size(
        config.boxConstraints.maxWidth,
        config.boxConstraints.maxHeight,
      );
    } else {
      BoxConstraints enforcedConstraints =
          _resolvedModuleBuilder.boxConstraints.enforce(config.boxConstraints);
      return new Size(
        enforcedConstraints.maxWidth,
        enforcedConstraints.maxHeight,
      );
    }
  }

  /// Get the child widget which represents the embedded module.
  /// If no module could be resolved, return the fallbackModule.
  Widget _getChildWidget() {
    if (_resolvedModuleBuilder != null) {
      return _resolvedModuleBuilder.buildWidget(config.data);
    } else {
      return config.fallbackModule;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size surfaceSize = _getSurfaceSize();
    return new Container(
      height: surfaceSize.height,
      width: surfaceSize.width,
      child: _getChildWidget(),
    );
  }
}
