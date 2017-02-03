// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// THIS IS A GENERATED FILE. DO NOT MODIFY MANUALLY.

import 'package:config_flutter/config.dart';
import 'package:flutter/material.dart';
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
  exampleWidth: null,
  exampleHeight: null,
);

/// Generated state object for this widget.
class _GeneratedGeneratorWidgetState extends GeneratedState {
  ModelFoo foo;
  ModelFoo foo2;
  ModelBar bar;
  ModelBaz baz;
  MockGenerator mockGenerator = new MockGenerator();

  _GeneratedGeneratorWidgetState(SetStateFunc setState) : super(setState);

  @override
  void initState(Config config) {
    foo = mockGenerator.foo();
    foo2 = mockGenerator.foo2();
    bar = mockGenerator.bar();
    baz = mockGenerator.baz();
  }

  @override
  Widget buildWidget(BuildContext context, Key key) {
    return new GeneratorWidget(
      key: key,
      foo: foo,
      foo2: foo2,
      bar: bar,
      baz: baz,
    );
  }

  @override
  List<TableRow> buildParameterTableRows(BuildContext context) {
    return <TableRow>[
      buildTableRow(
        context,
        <Widget>[
          new Text('ModelFoo'),
          new Text('foo'),
          new RegenerateButton(
            onPressed: () {
              setState(() {
                foo = mockGenerator.foo();
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
              });
            },
            codeToDisplay: 'mockGenerator.baz()',
          ),
        ],
      ),
    ];
  }
}

/// State builder for this widget.
final GeneratedStateBuilder kBuilder =
    (SetStateFunc setState) => new _GeneratedGeneratorWidgetState(setState);
