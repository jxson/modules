// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:config_flutter/config.dart';
import 'package:flutter/material.dart';
import 'package:widgets/email.dart';

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
    title: 'Email - List',
    subtitle: 'A list view of a Gmail mobile style inbox.',
    group: GalleryGroups.screen,
    href: '/email/list',
    builder: (BuildContext context, GalleryItem item, Config config) =>
        galleryScaffoldedScreen(item.title, new EmailListScreen()),
  ),
  new GalleryItem(
    title: 'Email - List (Single Line)',
    subtitle: 'A list view of a Gmail web style inbox.',
    group: GalleryGroups.screen,
    href: '/email/list_single',
    builder: (BuildContext context, GalleryItem item, Config config) =>
        galleryScaffoldedScreen(
            item.title, new EmailListScreen(style: InboxStyle.singleLine)),
  ),
  new GalleryItem(
    title: 'Email - List (Grid View)',
    subtitle: 'A list view of a Gmail web style inbox.',
    group: GalleryGroups.screen,
    href: '/email/list_grid',
    builder: (BuildContext context, GalleryItem item, Config config) =>
        galleryScaffoldedScreen(
            item.title, new EmailListScreen(style: InboxStyle.gridView)),
  ),
  new GalleryItem(
    title: 'Email - Thread',
    subtitle: 'A single Gmail style email thread',
    group: GalleryGroups.screen,
    href: '/email/thread',
    builder: (BuildContext context, GalleryItem item, Config config) =>
        galleryScaffoldedScreen(item.title, new EmailThreadScreen()),
  ),
  new GalleryItem(
    title: 'Email - Editor',
    subtitle: 'A Google Inbox style email editor',
    group: GalleryGroups.screen,
    href: '/email/editor',
    builder: (BuildContext context, GalleryItem item, Config config) =>
        galleryScaffoldedScreen(item.title, new EmailEditorScreen()),
  ),
  new GalleryItem(
    title: 'Email - Nav',
    subtitle: 'A Google Gmail style main menu',
    group: GalleryGroups.screen,
    href: '/email/nav',
    builder: (BuildContext context, GalleryItem item, Config config) =>
        galleryScaffoldedScreen(item.title, new EmailNavScreen()),
  ),
  new GalleryItem(
    title: 'Contact - Details',
    subtitle: 'Contact Details',
    group: GalleryGroups.screen,
    href: '/contact/details',
    builder: (BuildContext context, GalleryItem item, Config config) =>
        galleryScaffoldedScreen(item.title, new ContactDetailsScreen()),
  ),
  new GalleryItem(
    title: 'Youtube - Thumbnail',
    subtitle: 'Youtube Thumbnail',
    group: GalleryGroups.screen,
    href: '/youtube/thumbnail',
    builder: (BuildContext context, GalleryItem item, Config config) =>
        galleryScaffoldedScreen(item.title, new YoutubeThumbnailScreen()),
  ),
  new GalleryItem(
    title: 'Youtube - Player',
    subtitle: 'Youtube Player',
    group: GalleryGroups.screen,
    href: '/youtube/player',
    builder: (BuildContext context, GalleryItem item, Config config) {
      try {
        String apiKey = config.get('google_api_key');
        return galleryScaffoldedScreen(
            item.title,
            new YoutubePlayerScreen(
              apiKey: apiKey,
            ));
      } catch (e) {
        return new ErrorScreen(e.toString());
      }
    },
  ),
  new GalleryItem(
    title: 'Maps - StaticMap',
    subtitle: 'Static Map',
    group: GalleryGroups.screen,
    href: '/map/static',
    builder: (BuildContext context, GalleryItem item, Config config) {
      try {
        String apiKey = config.get('google_api_key');
        return galleryScaffoldedScreen(
            item.title,
            new StaticMapScreen(
              apiKey: apiKey,
            ));
      } catch (e) {
        return new ErrorScreen(e.toString());
      }
    },
  ),
  new GalleryItem(
    title: 'USPS - Tracking Status',
    subtitle: 'UPSP Tracking Status',
    group: GalleryGroups.screen,
    href: '/usps/tracking_status',
    builder: (BuildContext context, GalleryItem item, Config config) {
      try {
        String uspsApiKey = config.get('usps_api_key');
        String mapsApiKey = config.get('google_api_key');
        return galleryScaffoldedScreen(
            item.title,
            new TrackingStatusScreen(
              uspsApiKey: uspsApiKey,
              mapsApiKey: mapsApiKey,
            ));
      } catch (e) {
        return new ErrorScreen(e.toString());
      }
    },
  ),
  new GalleryItem(
    title: 'Widgets Gallery',
    subtitle: 'Widgets Gallery',
    group: GalleryGroups.screen,
    href: '/widgets',
    builder: (BuildContext context, GalleryItem item, Config config) =>
        galleryScaffoldedScreen(
            item.title, new WidgetsGalleryScreen(config: config)),
  ),
];
