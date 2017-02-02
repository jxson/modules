// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// THIS IS A GENERATED FILE. DO NOT MODIFY MANUALLY.

import 'package:config_flutter/config.dart';
import 'package:flutter/material.dart';
import 'package:gallery/src/widget_specs/typedefs.dart';
import 'package:gallery/src/widget_specs/utils.dart';
import 'package:widget_specs/widget_specs.dart';
import 'package:mock_package/exported.dart';

/// Name of the widget.
const String kName = 'ConfigKeyWidget';

/// [WidgetSpecs] of this widget.
final WidgetSpecs kSpecs = new WidgetSpecs(
  packageName: 'mock_package',
  name: 'ConfigKeyWidget',
  path: 'exported.dart',
  doc: '''
Sample widget for demonstrating the use of @ConfigKey annotation.''',
  exampleWidth: null,
  exampleHeight: null,
);

/// Helper widget.
class _HelperWidget extends StatefulWidget {
  final Config config;
  final double width;
  final double height;

  _HelperWidget(this.config, this.width, this.height);

  @override
  _HelperWidgetState createState() => new _HelperWidgetState();
}

/// Helper widget state.
class _HelperWidgetState extends State<_HelperWidget> {
  String apiKey;

  Key uniqueKey = new UniqueKey();

  @override
  void initState() {
    super.initState();

    apiKey = config.config.get('api_key');
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    try {
      widget = new ConfigKeyWidget(
        key: uniqueKey,
        apiKey: apiKey,
      );
    } catch (e) {
      widget = new Text('Failed to build the widget.\n'
          'See the error message below:\n\n'
          '$e');
    }

    return new Block(children: <Widget>[
      new Container(
        decoration: new BoxDecoration(
          border: new Border.all(color: Colors.grey[500]),
          borderRadius: new BorderRadius.all(new Radius.circular(4.0)),
        ),
        margin: const EdgeInsets.all(16.0),
        child: new Container(
          child: new Container(
            margin: const EdgeInsets.all(16.0),
            child: new Block(
              children: <Widget>[
                new Text(
                  'Parameters',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
                new Table(
                  children: <TableRow>[
                    buildTableRow(
                      context,
                      <Widget>[
                        new Text('String'),
                        new Text('apiKey'),
                        new ConfigKeyText(
                          configKey: 'api_key',
                          configValue: apiKey,
                        ),
                      ],
                    ),
                  ],
                  columnWidths: <int, TableColumnWidth>{
                    0: const IntrinsicColumnWidth(),
                    1: const FixedColumnWidth(16.0),
                    2: const IntrinsicColumnWidth(),
                    3: const FixedColumnWidth(16.0),
                    4: const FlexColumnWidth(1.0),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                ),
              ],
            ),
          ),
        ),
      ),
      new Container(
        decoration: new BoxDecoration(
          border: new Border.all(color: Colors.grey[500]),
          borderRadius: new BorderRadius.all(new Radius.circular(4.0)),
        ),
        margin: const EdgeInsets.all(16.0),
        child: new Container(
          margin: const EdgeInsets.all(16.0),
          child: new Row(
            children: <Widget>[
              new Container(
                width: config.width,
                height: config.height,
                child: widget,
              ),
              new Expanded(child: new Container()),
            ],
          ),
        ),
      ),
    ]);
  }

  void updateKey() {
    uniqueKey = new UniqueKey();
  }
}

/// Builder for this widget.
final GalleryWidgetBuilder kBuilder =
    (BuildContext context, Config config, double width, double height) =>
        new _HelperWidget(config, width, height);
