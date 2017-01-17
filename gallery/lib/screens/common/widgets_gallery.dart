// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gallery/src/generated/index.dart';
import 'package:widget_specs/widget_specs.dart';

/// A gallery screen that lists all the auto-generated widgets and their specs.
class WidgetsGalleryScreen extends StatefulWidget {
  @override
  _WidgetsGalleryState createState() => new _WidgetsGalleryState();
}

class _WidgetsGalleryState extends State<WidgetsGalleryScreen> {
  String selectedWidget;

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        _buildMenu(),
        new Expanded(child: _buildContents()),
      ],
    );
  }

  Widget _buildMenu() {
    List<String> widgetNames = kWidgetSpecs.keys.toList()..sort();
    List<ListItem> items = widgetNames
        .map((String name) => kWidgetSpecs[name])
        .map((WidgetSpecs specs) => new ListItem(
              title: new Text(specs.name),
              subtitle: new Text(specs.doc?.split('\n')?.first),
              onTap: () => setState(() => selectedWidget = specs.name),
            ))
        .toList();

    return new Drawer(
      child: new Block(children: items),
      elevation: 4,
    );
  }

  Widget _buildContents() {
    WidgetSpecs specs = kWidgetSpecs[selectedWidget];
    if (specs == null) {
      return new Center(
        child: new Text('Please select a widget from the left pane.'),
      );
    }

    // Display the widget name as heading 1, follwed by the dartdoc comments.
    String markdownText = '''# ${specs.name}

${specs.doc}''';

    return new Align(
      alignment: FractionalOffset.topLeft,
      child: new Block(
        children: <Widget>[
          new Markdown(
            data: markdownText,
            markdownStyle: new MarkdownStyle.largeFromTheme(Theme.of(context)),
          ),
        ],
      ),
    );
  }
}
