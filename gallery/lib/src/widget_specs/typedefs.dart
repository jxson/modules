// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:config_flutter/config.dart';
import 'package:flutter/widgets.dart';

/// WidgetBuilder for the widgets gallery.
typedef Widget GalleryWidgetBuilder(
  BuildContext context,
  Config config,
  double width,
  double height,
);
