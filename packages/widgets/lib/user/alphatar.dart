// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// [Alphatar] is a [StatefulWidget]
///
/// Alphatar is a 'circle avatar' to represent user profiles
/// If no avatar URL is given for an Alphatar, then the letter of the users name
/// along with a colored circle background will be used.
class Alphatar extends StatefulWidget {
  /// The [Image] to be displayed.
  final Image avatarImage;

  /// The fall-back letter to display when the image is not provided.
  final String letter;

  /// Size of alphatar. Default is 40.0
  final double size;

  /// Creates a new [Alphatar] with the given [Image].
  ///
  /// Either the avatarImage or the letter must be provided.
  Alphatar({Key key, this.avatarImage, this.letter, this.size: 40.0})
      : super(key: key) {
    assert(avatarImage != null || letter != null);
  }

  /// Creates a new [Alphatar] with the given URL.
  ///
  /// Either the avatarUrl or the letter must be provided.
  Alphatar.withUrl(
      {Key key, @required String avatarUrl, String letter, double size: 40.0})
      : this(
          key: key,
          avatarImage: avatarUrl != null
              ? new Image.network(
                  avatarUrl,
                  width: size,
                  height: size,
                  fit: ImageFit.cover,
                )
              : null,
          letter: letter,
          size: size,
        );

  @override
  _AlphatarState createState() => new _AlphatarState();
}

class _AlphatarState extends State<Alphatar> {
  /// Holds all the allowed background colors.
  ///
  /// From each material design primary color swatch, the first dark background
  /// that needs to be used with white text is chosen.
  static List<Color> _allowedColors = <Color>[
    Colors.red[400],
    Colors.pink[300],
    Colors.purple[300],
    Colors.deepPurple[300],
    Colors.indigo[300],
    Colors.blue[500],
    Colors.lightBlue[600],
    Colors.cyan[700],
    Colors.teal[500],
    Colors.green[600],
    Colors.lightGreen[700],
    Colors.lime[900],
    Colors.orange[800],
    Colors.deepOrange[500],
    Colors.brown[300],
  ];

  /// Background [Color] to be used when displaying the fall-back letter.
  Color _background;

  @override
  void initState() {
    super.initState();

    // Initialize the background color, if needed.
    // The same color should be reused in subsequent re-rendering.
    //
    // TODO(youngseokyoon): figure out a way to associate this color to the
    // user, so that the same user always gets the same background color.
    // Ref: https://fuchsia.atlassian.net/browse/SO-13
    if (config.avatarImage == null) {
      _background = _pickRandomBackgroundColor();
    }
  }

  Color _pickRandomBackgroundColor() {
    return _allowedColors[new Random().nextInt(_allowedColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: config.size,
      height: config.size,
      child: new ClipOval(
        child: config.avatarImage ?? _buildLetter(),
      ),
    );
  }

  Widget _buildLetter() {
    return new Container(
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        backgroundColor: _background,
        shape: BoxShape.circle,
      ),
      child: new Text(
        config.letter,
        style: new TextStyle(
          color: Colors.white,
          fontSize: config.size * 2 / 3,
        ),
      ),
    );
  }
}
