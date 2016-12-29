// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';

import 'package:config_flutter/config.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'groups.dart';

/// Used to build the widgets that hold the UI for [GalleryItem] instances.
typedef Widget GalleryPageBuilder(
    BuildContext context, GalleryItem galleryItem, Config config);

/// A [Widget] for gallery list items.
///
/// When a [GalleryItem] is tapped is considered selected and will navigate
/// the user to [href].
class GalleryItem extends StatelessWidget {
  /// Creates a GalleryItem.
  GalleryItem(
      {@required this.title,
      @required this.subtitle,
      @required this.group,
      @required this.href,
      @required this.builder}) {
    assert(title != null);
    assert(subtitle != null);
    assert(group != null);
    assert(href != null);
    assert(builder != null);
  }

  /// The title for the list item.
  final String title;

  /// The subtitle for the list item.
  final String subtitle;

  /// The type of gallery item defined in the [GalleryGroups] enum.
  final GalleryGroups group;

  /// The href to redirect the user to onTap.
  final String href;

  /// The [Widget] builder for this gallery item.
  final GalleryPageBuilder builder;

  @override
  Widget build(BuildContext context) {
    return new ListItem(
      title: new Text(title),
      subtitle: new Text(subtitle),
      onTap: () {
        Timeline.instantSync('Start Transition',
            arguments: <String, dynamic>{'from': '/', 'to': href});
        Navigator.pushNamed(context, href);
      },
    );
  }
}
