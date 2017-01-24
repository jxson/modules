// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gallery/src/generated/index.dart';
import 'package:widget_specs/widget_specs.dart';

const double _kMaxWidth = 1000.0;
const double _kMaxHeight = 1000.0;
const double _kDefaultWidth = 500.0;
const double _kDefaultHeight = 500.0;

/// A gallery screen that lists all the auto-generated widgets and their specs.
class WidgetsGalleryScreen extends StatefulWidget {
  @override
  _WidgetsGalleryState createState() => new _WidgetsGalleryState();
}

class _WidgetsGalleryState extends State<WidgetsGalleryScreen> {
  String selectedWidget;
  double width;
  double height;

  _WidgetsGalleryState() {
    width = _kDefaultWidth;
    height = _kDefaultHeight;
  }

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

${specs.doc}

#### Location

${specs.pathFromFuchsiaRoot != null ? '**Defined In**: `FUCHSIA_ROOT/${specs.pathFromFuchsiaRoot}`' : ''}

**Import Path**: `package:${specs.packageName}/${specs.path}`

''';

    return new Align(
      alignment: FractionalOffset.topLeft,
      child: new Block(
        children: <Widget>[
          new Markdown(
            data: markdownText,
            markdownStyle: new MarkdownStyle.largeFromTheme(Theme.of(context)),
          ),
          _buildSizeControl(),
          kWidgetBuilders[specs.name](context, width, height),
        ],
      ),
    );
  }

  Widget _buildSizeControl() {
    return new Container(
      decoration: new BoxDecoration(
        border: new Border.all(color: Colors.grey[500]),
        borderRadius: new BorderRadius.all(new Radius.circular(4.0)),
      ),
      margin: const EdgeInsets.all(16.0),
      child: new Container(
        alignment: FractionalOffset.topLeft,
        margin: const EdgeInsets.all(16.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Container(
                  width: 100.0,
                  child: new Text('Width: ${width.toStringAsFixed(1)}'),
                ),
                new Expanded(
                  child: new Slider(
                    value: width,
                    onChanged: (double value) => setState(() => width = value),
                    min: 0.0,
                    max: _kMaxWidth,
                  ),
                ),
              ],
            ),
            new Row(
              children: <Widget>[
                new Container(
                  width: 100.0,
                  child: new Text('Height: ${height.toStringAsFixed(1)}'),
                ),
                new Expanded(
                  child: new Slider(
                    value: height,
                    onChanged: (double value) => setState(() => height = value),
                    min: 0.0,
                    max: _kMaxHeight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
