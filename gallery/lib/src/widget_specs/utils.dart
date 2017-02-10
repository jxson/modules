// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:config_flutter/config.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

const double _kTableRowVerticalMargin = 5.0;
const double _kMargin = 16.0;
const double _kBoxRadius = 4.0;

final TextStyle _kInfoStyle = new TextStyle(
  color: Colors.grey[600],
  fontStyle: FontStyle.italic,
);

final TextStyle _kCodeStyle = new TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
);

/// A function type to be used as setState() function.
typedef void SetStateFunc(VoidCallback fn);

/// A class containing all the generated state values and widget builders.
///
/// The concrete implementations of this class should be provided by the
/// `gen_widget_specs` tool.
abstract class GeneratedState {
  /// The `setState` function provided by the [GalleryWidgetWrapperState].
  final SetStateFunc setState;

  /// Creates a new instance of [GeneratedState] object with the given
  /// [setState] function.
  GeneratedState(this.setState);

  /// Initialize all the parameter values.
  void initState(Config config);

  /// Builds the target widget with the current values.
  Widget buildWidget(BuildContext context, Key key);

  /// Builds the [TableRow]s, each of which represents a parameter description
  /// and its controller widgets.
  List<TableRow> buildParameterTableRows(BuildContext context);
}

/// Builder function for the [GeneratedState].
typedef GeneratedState GeneratedStateBuilder(SetStateFunc setState);

/// A widget that wraps the target widget and its size control panel.
class GalleryWidgetWrapper extends StatefulWidget {
  /// Config object.
  final Config config;

  /// Current width value.
  final double width;

  /// Current height value.
  final double height;

  /// The state builder provided for the target widget.
  final GeneratedStateBuilder stateBuilder;

  /// Creates a new instance of [GalleryWidgetWrapper].
  GalleryWidgetWrapper({
    Key key,
    @required this.config,
    @required this.width,
    @required this.height,
    @required this.stateBuilder,
  })
      : super(key: key);

  @override
  GalleryWidgetWrapperState createState() => new GalleryWidgetWrapperState();
}

/// The [State] class for the [GalleryWidgetWrapper].
///
/// The most important states are in fact stored in the [genState] field.
class GalleryWidgetWrapperState extends State<GalleryWidgetWrapper> {
  /// A [UniqueKey] to be used for the target widget.
  Key uniqueKey = new UniqueKey();

  /// An internal, generated state object that manages widget-specific states.
  GeneratedState genState;

  @override
  void initState() {
    super.initState();

    genState = config.stateBuilder((VoidCallback fn) {
      setState(() {
        fn?.call();
        _updateKey();
      });
    });

    genState.initState(config.config);
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    try {
      widget = genState.buildWidget(context, uniqueKey);
    } catch (e) {
      widget = new Text('Failed to build the widget.\n'
          'See the error message below:\n\n'
          '$e');
    }

    return new ListView(shrinkWrap: true, children: <Widget>[
      new Container(
        decoration: new BoxDecoration(
          border: new Border.all(color: Colors.grey[500]),
          borderRadius: new BorderRadius.all(new Radius.circular(_kBoxRadius)),
        ),
        margin: const EdgeInsets.all(_kMargin),
        child: new Container(
          child: new Container(
            margin: const EdgeInsets.all(_kMargin),
            child: new ListView(
              shrinkWrap: true,
              children: <Widget>[
                new Text(
                  'Parameters',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
                new Table(
                  children: genState.buildParameterTableRows(context),
                  columnWidths: <int, TableColumnWidth>{
                    0: const IntrinsicColumnWidth(),
                    1: const FixedColumnWidth(_kMargin),
                    2: const IntrinsicColumnWidth(),
                    3: const FixedColumnWidth(_kMargin),
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
          borderRadius: new BorderRadius.all(new Radius.circular(_kBoxRadius)),
        ),
        margin: const EdgeInsets.all(_kMargin),
        child: new Container(
          margin: const EdgeInsets.all(_kMargin),
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

  void _updateKey() {
    uniqueKey = new UniqueKey();
  }
}

/// Wrapper widget which gives some top margin to a given child.
class _TopMargined extends StatelessWidget {
  _TopMargined({
    Key key,
    @required this.child,
  })
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: _kTableRowVerticalMargin),
      child: child,
    );
  }
}

/// Builds a [TableRow] representing a parameter for a widget.
TableRow buildTableRow(BuildContext context, List<Widget> children) {
  assert(context != null);
  assert(children.length == 3);

  return new TableRow(
    children: <Widget>[
      new _TopMargined(
        child: new DefaultTextStyle.merge(
          context: context,
          style: _kCodeStyle,
          child: children[0],
        ),
      ),
      new Container(), // Empty column
      new _TopMargined(
        child: new DefaultTextStyle.merge(
          context: context,
          style: _kCodeStyle,
          child: children[1],
        ),
      ),
      new Container(), // Empty column
      new _TopMargined(
        child: children[2],
      )
    ],
  );
}

/// Regenerate button.
class RegenerateButton extends StatelessWidget {
  /// A callback function to be called when this button is pressed.
  final VoidCallback onPressed;

  /// A code snippet to display along with the button.
  final String codeToDisplay;

  /// Creates a new instance of [RegenerateButton].
  RegenerateButton({
    Key key,
    @required this.onPressed,
    this.codeToDisplay,
  })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String text =
        codeToDisplay != null ? 'Regenerate ($codeToDisplay)' : 'Regenerate';
    return new Row(
      children: <Widget>[
        new RaisedButton(
          onPressed: onPressed,
          child: new Text(text),
        ),
        new Expanded(child: new Container()),
      ],
    );
  }
}

/// A text widget for information displayed in the parameter tuning panel.
class InfoText extends Text {
  /// Creates a new instance of [InfoText].
  InfoText(String text, {Key key})
      : super(
          text,
          key: key,
          style: _kInfoStyle,
        );
}

/// A widget indicating whether a config value has been successfully retrieved.
class ConfigKeyText extends StatelessWidget {
  /// The key name of the config value specified in the `@ConfigKey` annotation.
  final String configKey;

  /// The value associated with the key.
  final String configValue;

  /// Creates a new instance of [ConfigKeyText].
  ConfigKeyText({
    Key key,
    @required this.configKey,
    @required this.configValue,
  })
      : super(key: key) {
    assert(configKey != null);
  }

  @override
  Widget build(BuildContext context) {
    if (configValue == null) {
      return new InfoText(
        "WARNING: Could not find the '$configKey' value "
            'from the config.json file.',
      );
    }

    return new InfoText(
      "'$configKey' value retrieved from the config.json file.",
    );
  }
}
