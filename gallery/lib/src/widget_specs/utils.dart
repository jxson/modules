// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

const double _kMargin = 10.0;

/// Wrapper widget which gives some top margin to a given child.
class _TopMargined extends StatelessWidget {
  _TopMargined({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.only(top: _kMargin),
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
