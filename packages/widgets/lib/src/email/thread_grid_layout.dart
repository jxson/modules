// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// The uniform Spacing/padding between grid items
const double _kGridSpacing = 16.0;

/// Target uniform width for all grid items
const double _kTargetGridWidth = 360.0;

/// UI Widget for a grid layout of ThreadGridItems
class ThreadGridLayout extends StatelessWidget {
  /// List of children widgets, ideally ThreadGridItems
  final List<Widget> children;

  /// ThreadGridLayout
  ThreadGridLayout({
    Key key,
    @required this.children,
  })
      : super(key: key) {
    assert(children != null);
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      // set column count
      int columnCount = (constraints.maxWidth / 360).round();
      if (columnCount == 0) {
        columnCount = 1;
      }

      // Track each column as a list of widgets
      List<List<Widget>> columnChildren = <List<Widget>>[];
      for (int i = 0; i < columnCount; i++) {
        columnChildren.add(<Widget>[]);
      }

      // Place each child widget in the appropiate column
      for (int i = 0; i < children.length; i++) {
        int columnIndex = i % columnCount;
        columnChildren[columnIndex].add(new Container(
          padding: const EdgeInsets.all(_kGridSpacing / 2.0),
          child: children[i],
        ));
      }

      // Give columns equal flex value to ensure that the widths are equally
      // distributed.
      List<Widget> columns = <Widget>[];
      for (int i = 0; i < columnCount; i++) {
        columns.add(new Expanded(
          flex: 1,
          child: new Column(
            children: columnChildren[i],
          ),
        ));
      }

      return new Container(
        padding: const EdgeInsets.all(_kGridSpacing / 2.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columns,
        ),
      );
    });
  }
}
