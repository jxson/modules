// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:widgets/email.dart';

/// A screen demonstrating what the email quarterback module should look like.
///
/// This screen has three columns as a typical email client in landscape mode:
/// folder list, thread list, and thread details.
class EmailQuarterbackModule extends StatelessWidget {
  /// Create a new [EmailQuarterbackModule] instance.
  EmailQuarterbackModule({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The container below should ideally be a ChildView.
    Widget menu = new Container(
      constraints: new BoxConstraints.loose(new Size.fromWidth(280.0)),
      child: new EmailMenuScreen(),
    );

    Widget inbox = new Container(
      margin: new EdgeInsets.symmetric(horizontal: 4.0),
      child: new Material(
        elevation: 2,
        // The container below should ideally be a ChildView.
        child: new Container(
          alignment: FractionalOffset.topCenter,
          constraints: new BoxConstraints.loose(new Size.fromWidth(400.0)),
          decoration: new BoxDecoration(backgroundColor: Colors.white),
          child: new EmailInboxScreen(),
        ),
      ),
    );

    Widget thread = new Flexible(
      flex: 1,
      // The container below should ideally be a ChildView.
      child: new Container(
        child: new EmailThreadScreen(),
      ),
    );

    List<Widget> columns = <Widget>[menu, inbox, thread];
    return new Material(
      color: Colors.white,
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns,
      ),
    );
  }
}
