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
    title: 'Email - Inbox',
    subtitle: 'A list view of a Gmail style inbox.',
    group: GalleryGroups.screen,
    href: '/email/inbox',
    builder: (BuildContext context) => new EmailInboxScreen(),
  ),
  new GalleryItem(
    title: 'Email - Thread',
    subtitle: 'A single Gmail style email thread',
    group: GalleryGroups.screen,
    href: '/email/thread',
    builder: (BuildContext context) => new EmailThreadScreen(),
  ),
  new GalleryItem(
    title: 'Email - Editor',
    subtitle: 'A Google Inbox style email editor',
    group: GalleryGroups.screen,
    href: '/email/editor',
    builder: (BuildContext context) => new EmailEditorScreen(),
  ),
  new GalleryItem(
    title: 'Email - Menu',
    subtitle: 'A Google Gmail style main menu',
    group: GalleryGroups.screen,
    href: '/email/menu',
    builder: (BuildContext context) => new EmailMenuScreen(),
  ),
];
