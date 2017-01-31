// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

const double _kTableRowVerticalMargin = 5.0;
const double _kMargin = 16.0;

TextStyle _kInfoStyle = new TextStyle(
  color: Colors.grey[600],
  fontStyle: FontStyle.italic,
);

TextStyle _kCodeStyle = new TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
);

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
