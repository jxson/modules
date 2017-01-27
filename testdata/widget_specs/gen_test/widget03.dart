// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// THIS IS A GENERATED FILE. DO NOT MODIFY MANUALLY.

import 'package:flutter/material.dart';
import 'package:gallery/src/widget_specs/typedefs.dart';
import 'package:gallery/src/widget_specs/utils.dart';
import 'package:widget_specs/widget_specs.dart';
import 'package:mock_package/exported.dart';

import 'package:mock_package/src/sample_widgets.dart';

/// Name of the widget.
const String kName = 'Widget03';

/// [WidgetSpecs] of this widget.
final WidgetSpecs kSpecs = new WidgetSpecs(
  packageName: 'mock_package',
  name: 'Widget03',
  path: 'exported.dart',
  doc: '''
This is a public [StatelessWidget].''',
);

/// Helper widget.
class _HelperWidget extends StatefulWidget {
  final double width;
  final double height;

  _HelperWidget(this.width, this.height);

  @override
  _HelperWidgetState createState() => new _HelperWidgetState();
}

/// Helper widget state.
class _HelperWidgetState extends State<_HelperWidget> {
  CallbackWithNoParams callbackWithNoParams;
  CallbackWithParams callbackWithParams;

  Key uniqueKey = new UniqueKey();

  @override
  void initState() {
    super.initState();

    callbackWithNoParams = () => print('Widget03.callbackWithNoParams called');
    callbackWithParams = (dynamic foo, dynamic bar) => print(
        'Widget03.callbackWithParams called with parameters: ${<dynamic>[foo, bar]}');
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    try {
      widget = new Widget03(
        key: uniqueKey,
        callbackWithNoParams: callbackWithNoParams,
        callbackWithParams: callbackWithParams,
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
                        new Text('CallbackWithNoParams'),
                        new Text('callbackWithNoParams'),
                        new Text('Default implementation'),
                      ],
                    ),
                    buildTableRow(
                      context,
                      <Widget>[
                        new Text('CallbackWithParams'),
                        new Text('callbackWithParams'),
                        new Text('Default implementation'),
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
    (BuildContext context, double width, double height) =>
        new _HelperWidget(width, height);
