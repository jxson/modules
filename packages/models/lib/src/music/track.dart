// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'album.dart';
import 'artist.dart';
import 'representation_type.dart';

/// Represents a Musical Track
class Track {
  /// Name of track
  final String name;

  /// Artists who performed in track
  final List<Artist> artists;

  /// Album on which the track apperas
  final Album album;

  /// Duration of track
  final Duration duration;

  /// Flag for if the track has EXPLICIT lyrics...GANGSTA!
  final bool explicit;

  /// Spotify ID of track
  final String id;

  /// The popularity of the track from 0-100
  final int popularity;

  /// The track number of this track in the album
  final int trackNumber;

  /// Representation type of this model
  final RepresentationType representation;

  /// Constructor
  Track({
    this.name,
    this.artists,
    this.album,
    this.duration,
    this.explicit,
    this.id,
    this.popularity,
    this.trackNumber,
    this.representation: RepresentationType.full,
  });

  /// Create a full track object form json data
  factory Track.fromFullJson(dynamic json) {
    return new Track(
      name: json['name'],
      artists: Artist.listFromJson(json['artists']),
      album: new Album.fromSimplifiedJson(json['album']),
      duration: new Duration(
          milliseconds: json['duration_ms'] is int
              ? json['duration_ms']
              : int.parse(json['duration_ms'])),
      explicit: json['explicit'],
      id: json['id'],
      popularity: json['popularity'],
      trackNumber: json['track_number'],
      representation: RepresentationType.full,
    );
  }

  /// Create a simplified track object from json data
  factory Track.fromSimplifiedJson(dynamic json) {
    return new Track(
      name: json['name'],
      artists: Artist.listFromJson(json['artists']),
      duration: new Duration(
          milliseconds: json['duration_ms'] is int
              ? json['duration_ms']
              : int.parse(json['duration_ms'])),
      explicit: json['explicit'],
      id: json['id'],
      trackNumber: json['track_number'],
      representation: RepresentationType.full,
    );
  }
}
