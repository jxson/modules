// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'app.dart';
import 'gallery/collection.dart';
import 'gallery/item.dart';

/// Constant value for the routes derieved from [kGalleryCollection].
final Map<String, WidgetBuilder> kRoutes =
    new Map<String, WidgetBuilder>.fromIterable(
  kGalleryCollection,
  key: (GalleryItem item) => item.href,
  value: (GalleryItem item) => (BuildContext context) {
        App app = context.ancestorWidgetOfExactType(App);
        return item.builder(context, item, app.config);
      },
);
