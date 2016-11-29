// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/music.dart';

/// UI Widget that represents a vertically orientated track player
class VerticalTrackPlayer extends StatelessWidget {
  /// Track to play
  final Track track;

  /// Album of track
  final Album album;

  /// Callback for pressing "next track" button
  final VoidCallback onPreviousTrack;

  /// Callback for pressing "previous track" button
  final VoidCallback onNextTrack;

  /// Constructor
  VerticalTrackPlayer({
    Key key,
    @required this.track,
    @required this.album,
    this.onNextTrack,
    this.onPreviousTrack,
  })
      : super(key: key) {
    assert(track != null);
    assert(album != null);
  }

  Widget _buildTrackInfo() {
    return new Container(
      padding: const EdgeInsets.symmetric(
        vertical: 36.0,
        horizontal: 24.0,
      ),
      decoration: new BoxDecoration(
        backgroundColor: Colors.blueGrey[800],
      ),
      constraints: const BoxConstraints.expand(),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Track name
          new Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: new Text(
              track.name,
              style: new TextStyle(
                color: Colors.white,
                fontSize: 22.0,
              ),
            ),
          ),
          // Artist name
          new Text(
            track.artists.first?.name,
            style: new TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackPlayer() {
    // TODO Playing Status
    return new Material(
      color: Colors.blueGrey[500],
      child: new Stack(
        children: <Widget>[
          new Container(
            height: 70.0,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new IconButton(
                  icon: new Icon(Icons.skip_previous),
                  color: Colors.white,
                  onPressed: () {
                    onPreviousTrack?.call();
                  },
                ),
                new IconButton(
                  icon: new Icon(Icons.play_arrow),
                  color: Colors.white,
                  onPressed: () {
                    // TODO(dayang): play/pause logic
                  },
                ),
                new IconButton(
                  icon: new Icon(Icons.skip_next),
                  color: Colors.white,
                  onPressed: () {
                    onNextTrack?.call();
                  },
                ),
              ],
            ),
          ),
          new Positioned(
            left: 0.0,
            top: 0.0,
            child: new Container(
              height: 6.0,
              width: 140.0,
              decoration: new BoxDecoration(
                backgroundColor: Colors.pink[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        // Album Art
        new Flexible(
          flex: 3,
          child: new Image.network(
            album.images.first.url,
            fit: ImageFit.cover,
          ),
        ),
        // Track Info
        new Flexible(
          flex: 1,
          child: _buildTrackInfo(),
        ),
        _buildTrackPlayer(),
      ],
    );
  }
}
