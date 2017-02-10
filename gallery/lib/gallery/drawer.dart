// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Navigation drawer for the FX Gallery.
class GalleryDrawer extends StatefulWidget {
  /// Create a [GalleryDrawer] instance, which is a material navigation drawer.
  GalleryDrawer({
    Key key,
    this.showPerformanceOverlay,
    this.onShowPerformanceOverlayChanged,
  })
      : super(key: key);

  /// Indicates whether the performance overlay should be shown.
  bool showPerformanceOverlay = false;

  /// A callback function to be called when the 'Performance Overlay' checkbox
  /// value is changed.
  ValueChanged<bool> onShowPerformanceOverlayChanged;

  @override
  _GalleryDrawerState createState() => new _GalleryDrawerState();
}

class _GalleryDrawerState extends State<GalleryDrawer> {
  @override
  Widget build(BuildContext context) {
    final double systemTopPadding = MediaQuery.of(context).padding.top;

    List<Widget> drawerItems = <Widget>[];

    drawerItems.add(new Container(height: systemTopPadding));

    // 'Debug Menu' subheader
    TextStyle subheaderStyle = Theme.of(context).textTheme.body2;
    subheaderStyle = subheaderStyle.copyWith(
      color: subheaderStyle.color.withOpacity(0.54),
    );

    drawerItems.add(new DrawerItem(
      icon: null,
      child: new Text(
        'Debug Menu',
        style: subheaderStyle,
      ),
    ));

    // Performance overlay
    if (config.onShowPerformanceOverlayChanged != null) {
      drawerItems.add(createCheckboxItem(
        icon: new Icon(Icons.assessment),
        text: 'Performance Overlay',
        value: config.showPerformanceOverlay,
        onChanged: config.onShowPerformanceOverlayChanged,
      ));
    }

    // Other debug paint menus
    drawerItems.add(createCheckboxItem(
      text: 'Debug Paint Size',
      value: debugPaintSizeEnabled,
      onChanged: (bool value) {
        setState(() {
          debugPaintSizeEnabled = value;
        });
      },
    ));

    drawerItems.add(createCheckboxItem(
      text: 'Debug Paint Baselines',
      value: debugPaintBaselinesEnabled,
      onChanged: (bool value) {
        setState(() {
          debugPaintBaselinesEnabled = value;
        });
      },
    ));

    drawerItems.add(createCheckboxItem(
      text: 'Debug Paint Pointers',
      value: debugPaintPointersEnabled,
      onChanged: (bool value) {
        setState(() {
          debugPaintPointersEnabled = value;
        });
      },
    ));

    drawerItems.add(createCheckboxItem(
      text: 'Debug Paint Layer Borders',
      value: debugPaintLayerBordersEnabled,
      onChanged: (bool value) {
        setState(() {
          debugPaintLayerBordersEnabled = value;
        });
      },
    ));

    drawerItems.add(createCheckboxItem(
      text: 'Debug Repaint Rainbow',
      value: debugRepaintRainbowEnabled,
      onChanged: (bool value) {
        setState(() {
          debugRepaintRainbowEnabled = value;
        });
      },
    ));

    return new Drawer(child: new ListView(children: drawerItems));
  }

  Widget createCheckboxItem({
    Icon icon: const Icon(Icons.developer_mode),
    String text,
    bool value,
    ValueChanged<bool> onChanged,
  }) {
    return new DrawerItem(
      icon: icon,
      child: new Row(
        children: <Widget>[
          new Expanded(child: new Text(text)),
          new Checkbox(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
