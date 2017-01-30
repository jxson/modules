// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/contact.dart';

import '../user/alphatar.dart';

const String _kDefaultBackgroundImage =
    'https://static.pexels.com/photos/2042/sea-city-mountains-landmark.jpg';

/// Height of header where background image is shown
const double _kHeaderHeight = 100.0;

/// Size (radius) of alphatar in Contact Detail
const double _kAlphatarDiameter = 100.0;

const double _kAlphatarBorderWidth = 1.0;

/// Contact Header contains the Alphatar, Background Image, Name and Location
/// of a contact. This is used primarily in the Contact Card
class ContactHeader extends StatelessWidget {
  /// User [Contact] that is being rendered
  final Contact contact;

  /// Constructor
  ContactHeader({
    Key key,
    @required this.contact,
  })
      : super(key: key) {
    assert(contact != null);
  }

  /// Build background image
  Widget _buildBackgroundImage(Color primaryColor) {
    return new Container(
      margin: const EdgeInsets.only(
          bottom: _kAlphatarDiameter / 2.0 + _kAlphatarBorderWidth),
      height: _kHeaderHeight,
      decoration: new BoxDecoration(
        backgroundImage: new BackgroundImage(
          image: new NetworkImage(contact.backgroundImageUrl != null
              ? contact.backgroundImageUrl
              : _kDefaultBackgroundImage),
          fit: ImageFit.cover,
          colorFilter: new ColorFilter.mode(
            primaryColor.withAlpha(30),
            BlendMode.color,
          ),
        ),
      ),
    );
  }

  /// Builds the centered alphatar section
  Widget _buildAlphatarSection(Color primaryColor) {
    return new Positioned.fill(
      child: new Align(
        alignment: FractionalOffset.bottomCenter,
        child: new Container(
          height: _kAlphatarDiameter + _kAlphatarBorderWidth * 2.0,
          padding: const EdgeInsets.all(_kAlphatarBorderWidth),
          decoration: new BoxDecoration(
            backgroundColor: primaryColor,
            shape: BoxShape.circle,
          ),
          child: new Alphatar.fromUser(
            user: contact.user,
            size: _kAlphatarDiameter,
          ),
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    List<Widget> children = <Widget>[
      new Container(
        margin: const EdgeInsets.only(bottom: 4.0),
        child: new Text(
          contact.user.name,
          style: new TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    ];

    if (contact.regionPreview != null) {
      children.add(
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.only(right: 4.0),
              child: new Icon(
                Icons.place,
                size: 14.0,
              ),
            ),
            new Text(
              contact.regionPreview,
            ),
          ],
        ),
      );
    }

    return new Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: new Center(
        child: new Column(
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      new Stack(
        children: <Widget>[
          _buildBackgroundImage(theme.primaryColor),
          _buildAlphatarSection(theme.primaryColor),
        ],
      ),
      _buildNameSection(),
    ]);
  }
}
