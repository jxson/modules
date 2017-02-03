// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/music.dart';
import 'package:music_api/music_api.dart';
import 'package:widgets_meta/widgets_meta.dart';

import 'loading_state.dart';
import 'related_artists.dart';
import 'vertical_track_player.dart';

/// UI Widget that represents the overview page of an album
@ExampleSize(800.0, 1000.0)
class AlbumPage extends StatefulWidget {
  /// Spotify Id of given album
  final String albumId;

  /// Called when the album data changes.
  ///
  /// The album page passes an [Album] object (or null) as a parameter to this
  /// callback.
  final ValueChanged<Album> onChanged;

  /// Constructor
  AlbumPage({
    Key key,
    @required @ExampleValue('0sNOF9WDwhWunNAHPD3Baj') this.albumId,
    this.onChanged,
  })
      : super(key: key) {
    assert(albumId != null);
  }

  @override
  _AlbumPageState createState() => new _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  /// Album after it has loaded
  Album _album;

  /// Current track select
  Track _currentTrack;

  /// Loading State for Album data
  LoadingState _loadingState = LoadingState.inProgress;

  @override
  void initState() {
    super.initState();
    MusicAPI.getAlbumById(config.albumId).then((Album album) {
      if (mounted) {
        config.onChanged?.call(album);
        if (album == null) {
          setState(() {
            _loadingState = LoadingState.failed;
          });
        } else {
          setState(() {
            _loadingState = LoadingState.completed;
            _album = album;
            _currentTrack = album.tracks?.first;
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

  Widget _buildTrackListItem({Track track}) {
    return new InkWell(
      onTap: () {
        setState(() {
          _currentTrack = track;
        });
      },
      child: new Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 16.0,
        ),
        child: new Row(
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: _currentTrack == track
                  ? new Icon(
                      Icons.play_circle_filled,
                      color: Colors.pink[500],
                    )
                  : new Icon(
                      Icons.play_circle_outline,
                      color: Colors.grey[300],
                    ),
            ),
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new Text(
                '${track.trackNumber}',
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            new Text(
              track.name,
              style: new TextStyle(
                fontWeight: _currentTrack == track
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackList() {
    List<Widget> children = <Widget>[];
    children.add(new Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: new Text(
        'TRACK LISTING',
        style: new TextStyle(
          color: Colors.pink[500],
          fontSize: 18.0,
        ),
      ),
    ));

    _album.tracks.forEach((Track track) {
      children.add(_buildTrackListItem(track: track));
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

  Widget _buildPage() {
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Expanded(
          flex: 3,
          child: new VerticalTrackPlayer(
            track: _currentTrack,
            album: _album,
            onNextTrack: _handleNextTrack,
            onPreviousTrack: _handlePreviousTrack,
          ),
        ),
        new Expanded(
          flex: 5,
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                flex: 3,
                child: new ListView(
                  children: <Widget>[
                    _buildTrackList(),
                  ],
                ),
              ),
              new Expanded(
                flex: 2,
                child: new ListView(
                  children: <Widget>[
                    new RelatedArtists(
                      artistId: _album.artists.first.id,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleNextTrack() {
    if (_currentTrack.trackNumber == _album.tracks.length) {
      setState(() {
        _currentTrack = _album.tracks.first;
      });
    } else {
      setState(() {
        _currentTrack = _album.tracks[_currentTrack.trackNumber];
      });
    }
  }

  void _handlePreviousTrack() {
    if (_currentTrack.trackNumber == 1) {
      setState(() {
        _currentTrack = _album.tracks.last;
      });
    } else {
      setState(() {
        _currentTrack = _album.tracks[_currentTrack.trackNumber - 2];
      });
    }
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
        page = _buildPage();
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
