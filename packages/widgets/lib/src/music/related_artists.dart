// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/music.dart';
import 'package:music_api/music_api.dart';
import 'package:widgets_meta/widgets_meta.dart';

import 'loading_state.dart';

/// UI Widget that shows related artists for a given artist
class RelatedArtists extends StatefulWidget {
  /// Spotify Id of given artist
  final String artistId;

  /// Constructor
  RelatedArtists({
    Key key,
    @required @ExampleValue('0OdUWJ0sBjDrqHygGUXeCF') this.artistId,
  })
      : super(key: key) {
    assert(artistId != null);
  }

  @override
  _RelatedArtistsState createState() => new _RelatedArtistsState();
}

class _RelatedArtistsState extends State<RelatedArtists> {
  /// Related artists
  List<Artist> _artists;

  /// Loading State for artists data
  LoadingState _loadingState = LoadingState.inProgress;

  @override
  void initState() {
    super.initState();
    MusicAPI.getRelatedArtists(config.artistId).then((List<Artist> artists) {
      if (mounted) {
        if (artists == null) {
          setState(() {
            _loadingState = LoadingState.failed;
          });
        } else {
          setState(() {
            _loadingState = LoadingState.completed;
            _artists = artists.sublist(0, 5);
          });
        }
      }
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _loadingState = LoadingState.failed;
        });
      }
    });
  }

  Widget _buildArtistPreview({Artist artist}) {
    return new Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 16.0,
      ),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
            width: 125.0,
            height: 125.0,
            margin: const EdgeInsets.only(right: 16.0),
            child: new Image.network(
              artist.images.first.url,
              fit: ImageFit.cover,
            ),
          ),
          new Expanded(
            flex: 1,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  artist.name,
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                new Text(
                  artist.genres.first,
                  style: new TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistList() {
    List<Widget> children = <Widget>[];
    children.add(new Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: new Text(
        'RELATED ARTISTS',
        style: new TextStyle(
          color: Colors.pink[500],
          fontSize: 18.0,
        ),
      ),
    ));

    _artists.forEach((Artist artist) {
      children.add(_buildArtistPreview(artist: artist));
    });

    return new Material(
      color: Colors.white,
      child: new Container(
        padding: const EdgeInsets.all(24.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_loadingState) {
      case LoadingState.inProgress:
        page = new Container(
          height: 100.0,
          child: new Center(
            child: new CircularProgressIndicator(
              value: null,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey[300]),
            ),
          ),
        );
        break;
      case LoadingState.completed:
        page = _buildArtistList();
        break;
      case LoadingState.failed:
        page = new Container(
          height: 100.0,
          child: new Text('Content Failed to Load'),
        );
        break;
    }
    return page;
  }
}
