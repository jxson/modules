// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'gallery/collection.dart';
import 'gallery/item.dart';
import 'screens/email/inbox.dart';
import 'screens/email/thread.dart';

/// Constant value for the routes derieved from [kGalleryCollection].
final Map<String, WidgetBuilder> kRoutes =
    new Map<String, WidgetBuilder>.fromIterable(kGalleryCollection,
        key: (GalleryItem item) => item.href,
        value: (GalleryItem item) => item.builder);

/// Custom route handling code for passing arguments to sub-screens.
Route<Null> handleRoute(RouteSettings settings) {
  // TODO(youngseokeoon): parse the parameters in a more structured way.
  // See: https://fuchsia.atlassian.net/browse/SO-12
  List<String> segments = settings.name.split('/');
  if (settings.name.startsWith('/email/inbox/')) {
    String accessToken = segments[3];
    return new MaterialPageRoute<Null>(
      settings: settings,
      builder: (BuildContext context) {
        return new EmailInboxScreen(accessToken: accessToken);
      },
    );
  } else if (settings.name.startsWith('/email/thread/')) {
    String accessToken = segments[3];
    String threadId = segments[4];
    return new MaterialPageRoute<Null>(
      settings: settings,
      builder: (BuildContext context) {
        return new EmailThreadScreen(
          accessToken: accessToken,
          threadId: threadId,
        );
      },
    );
  }

  return null;
}
