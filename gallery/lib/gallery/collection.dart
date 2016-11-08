// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../screens/index.dart';
import 'groups.dart';
import 'item.dart';

/// Wraps a gallery item in scaffolding, which includes app bar with title
StatefulWidget galleryScaffoldedScreen(String title, Widget content) {
  return new Scaffold(
    appBar: new AppBar(
      title: new Text(title),
    ),
    body: content,
  );
}

/// Holds a list of all [GalleryItem] instances.
final List<GalleryItem> kGalleryCollection = <GalleryItem>[
  new GalleryItem(
    title: 'Email - Inbox',
    subtitle: 'A list view of a Gmail mobile style inbox.',
    group: GalleryGroups.screen,
    href: '/email/inbox',
    builder: (BuildContext context, GalleryItem item) =>
        galleryScaffoldedScreen(item.title, new EmailInboxScreen()),
  ),
  new GalleryItem(
    title: 'Email - Inbox (Single Line)',
    subtitle: 'A list view of a Gmail web style inbox.',
    group: GalleryGroups.screen,
    href: '/email/inbox_single',
    builder: (BuildContext context, GalleryItem item) =>
        galleryScaffoldedScreen(
            item.title, new EmailInboxScreen(singleLine: true)),
  ),
  new GalleryItem(
    title: 'Email - Thread',
    subtitle: 'A single Gmail style email thread',
    group: GalleryGroups.screen,
    href: '/email/thread',
    builder: (BuildContext context, GalleryItem item) =>
        galleryScaffoldedScreen(
            item.title, new EmailThreadScreen(threadId: 'thread01')),
  ),
  new GalleryItem(
    title: 'Email - Editor',
    subtitle: 'A Google Inbox style email editor',
    group: GalleryGroups.screen,
    href: '/email/editor',
    builder: (BuildContext context, GalleryItem item) =>
        galleryScaffoldedScreen(item.title, new EmailEditorScreen()),
  ),
  new GalleryItem(
    title: 'Email - Menu',
    subtitle: 'A Google Gmail style main menu',
    group: GalleryGroups.screen,
    href: '/email/menu',
    builder: (BuildContext context, GalleryItem item) =>
        galleryScaffoldedScreen(item.title, new EmailMenuScreen()),
  ),
  new GalleryItem(
    title: 'Integrated Email Flow',
    subtitle: 'An integrated flow of email experience using real data',
    group: GalleryGroups.flow,
    href: '/flow/email',
    builder: (BuildContext context, GalleryItem item) =>
        galleryScaffoldedScreen(item.title, new FluxGalleryScreen()),
  ),
  new GalleryItem(
    title: 'Contact - Details',
    subtitle: 'Contact Details',
    group: GalleryGroups.screen,
    href: '/contact/details',
    builder: (BuildContext context, GalleryItem item) =>
        galleryScaffoldedScreen(item.title, new ContactDetailsScreen()),
  ),
  new GalleryItem(
    title: 'Youtube - Thumbnail',
    subtitle: 'Youtube Thumbnail',
    group: GalleryGroups.screen,
    href: '/youtube/thumbnail',
    builder: (BuildContext context, GalleryItem item) =>
        galleryScaffoldedScreen(item.title, new YoutubeThumbnailScreen()),
  ),
  new GalleryItem(
    title: 'Youtube - Player',
    subtitle: 'Youtube Player',
    group: GalleryGroups.screen,
    href: '/youtube/player',
    builder: (BuildContext context, GalleryItem item) =>
        galleryScaffoldedScreen(item.title, new YoutubePlayerScreen()),
  ),
];
