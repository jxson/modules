// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:auth/auth_credentials.dart';
import 'package:auth/login_screen.dart';
import 'package:flutter/material.dart';

import '../screens/index.dart';
import '../src/config.dart';
import 'groups.dart';
import 'item.dart';

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
  new GalleryItem(
    title: 'Integrated Email Flow',
    subtitle: 'An integrated flow of email experience using real data',
    group: GalleryGroups.flow,
    href: '/flow/email',
    builder: (BuildContext context) => new LoginScreen(
          clientId: kConfig['client_id'],
          clientSecret: kConfig['client_secret'],
          onLoginSuccess: (AuthCredentials credentials) {
            // Navigate to the EmailInboxScreen, with the obtained access token.
            Navigator.popAndPushNamed(
              context,
              '/email/inbox/${credentials.accessToken}',
            );
          },
        ),
  ),
];
