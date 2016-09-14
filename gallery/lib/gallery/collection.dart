// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../screens/index.dart';
import 'item.dart';
import 'groups.dart';

/// Holds a list of all [GalleryItem] instances.
final List<GalleryItem> kGalleryCollection = <GalleryItem>[
  new GalleryItem(
    title: 'Dummy Screen',
    subtitle: 'A dummy screen',
    group: GalleryGroups.screen,
    href: '/dummy/example',
    builder: (BuildContext context) => new DummyScreen(),
  ),
];
