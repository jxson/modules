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

import 'package:mock_package/src/mock_generator.dart';
import 'package:mock_package/src/mock_models.dart';

/// Name of the widget.
const String kName = 'GeneratorWidget';

/// [WidgetSpecs] of this widget.
final WidgetSpecs kSpecs = new WidgetSpecs(
  packageName: 'mock_package',
  name: 'GeneratorWidget',
  path: 'exported.dart',
  doc: '''
Sample widget for demonstrating the use of model classes annotated with
@Generator annotation.''',
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
  ModelFoo foo;
  ModelFoo foo2;
  ModelBar bar;
  ModelBaz baz;
  MockGenerator mockGenerator = new MockGenerator();

  Key uniqueKey = new UniqueKey();

  @override
  void initState() {
    super.initState();

    foo = mockGenerator.foo();
    foo2 = mockGenerator.foo2();
    bar = mockGenerator.bar();
    baz = mockGenerator.baz();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    try {
      widget = new GeneratorWidget(
        key: uniqueKey,
        foo: foo,
        foo2: foo2,
        bar: bar,
        baz: baz,
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
                        new Text('ModelFoo'),
                        new Text('foo'),
                        new RegenerateButton(
                          onPressed: () {
                            setState(() {
                              foo = mockGenerator.foo();
                              updateKey();
                            });
                          },
                          codeToDisplay: 'mockGenerator.foo()',
                        ),
                      ],
                    ),
                    buildTableRow(
                      context,
                      <Widget>[
                        new Text('ModelFoo'),
                        new Text('foo2'),
                        new RegenerateButton(
                          onPressed: () {
                            setState(() {
                              foo2 = mockGenerator.foo2();
                              updateKey();
                            });
                          },
                          codeToDisplay: 'mockGenerator.foo2()',
                        ),
                      ],
                    ),
                    buildTableRow(
                      context,
                      <Widget>[
                        new Text('ModelBar'),
                        new Text('bar'),
                        new RegenerateButton(
                          onPressed: () {
                            setState(() {
                              bar = mockGenerator.bar();
                              updateKey();
                            });
                          },
                          codeToDisplay: 'mockGenerator.bar()',
                        ),
                      ],
                    ),
                    buildTableRow(
                      context,
                      <Widget>[
                        new Text('ModelBaz'),
                        new Text('baz'),
                        new RegenerateButton(
                          onPressed: () {
                            setState(() {
                              baz = mockGenerator.baz();
                              updateKey();
                            });
                          },
                          codeToDisplay: 'mockGenerator.baz()',
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
