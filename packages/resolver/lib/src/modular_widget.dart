// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'module_capability.dart';
import 'module_data.dart';

/// Builds widgets that represent a Module
abstract class ModularWidgetBuilder {
  /// Creates widget given the module data
  Widget buildWidget(ModuleData data);

  /// Getter for BoxContraints for the given module
  BoxConstraints get boxConstraints;

  /// Getter for desired capabilities for given module
  List<ModuleCapability> get desiredCapabilities;
}
