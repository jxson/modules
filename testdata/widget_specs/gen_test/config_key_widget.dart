// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// THIS IS A GENERATED FILE. DO NOT MODIFY MANUALLY.

import 'package:config_flutter/config.dart';
import 'package:flutter/material.dart';
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

/// Generated state object for this widget.
class _GeneratedConfigKeyWidgetState extends GeneratedState {
  String apiKey;

  _GeneratedConfigKeyWidgetState(SetStateFunc setState) : super(setState);

  @override
  void initState(Config config) {
    apiKey = config.get('api_key');
  }

  @override
  Widget buildWidget(BuildContext context, Key key) {
    return new ConfigKeyWidget(
      key: key,
      apiKey: apiKey,
    );
  }

  @override
  List<TableRow> buildParameterTableRows(BuildContext context) {
    return <TableRow>[
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
    ];
  }
}

/// State builder for this widget.
final GeneratedStateBuilder kBuilder =
    (SetStateFunc setState) => new _GeneratedConfigKeyWidgetState(setState);
