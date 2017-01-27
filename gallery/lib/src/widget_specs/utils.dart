// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

const double _kTableRowVerticalMargin = 5.0;
const double _kMargin = 16.0;

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

  TextStyle codeTextStyle = new TextStyle(
    fontFamily: 'monospace',
    fontWeight: FontWeight.bold,
  );

  return new TableRow(
    children: <Widget>[
      new _TopMargined(
        child: new DefaultTextStyle.merge(
          context: context,
          style: codeTextStyle,
          child: children[0],
        ),
      ),
      new Container(), // Empty column
      new _TopMargined(
        child: new DefaultTextStyle.merge(
          context: context,
          style: codeTextStyle,
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
