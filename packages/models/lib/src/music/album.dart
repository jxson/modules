// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'artist.dart';
import 'music_image.dart';
import 'representation_type.dart';
import 'track.dart';

/// Represents an Album
class Album {
  /// The name of the album
  final String name;

  /// Artists of the album
  final List<Artist> artists;

  /// Cover art for the album
  final List<MusicImage> images;

  /// Tracks in album
  final List<Track> tracks;

  /// Spotify ID of album
  final String id;

  /// Date when album was first released
  final String releaseDate;

  /// The popularity of the album from 0-100
  final int popularity;

  /// Representation type of this model
  final RepresentationType representation;

  /// Constructor
  Album({
    this.name,
    this.artists,
    this.images,
    this.tracks,
    this.id,
    this.releaseDate,
    this.popularity,
    this.representation: RepresentationType.full,
  });

  /// Create a full album object from json data
  factory Album.fromFullJson(dynamic json) {
    // Format list of tracks
    List<Track> tracks = <Track>[];
    if (json['tracks']['items'] is List<dynamic>) {
      List<dynamic> jsonList = json['tracks']['items'];
      jsonList.forEach((dynamic trackJson) {
        tracks.add(new Track.fromSimplifiedJson(trackJson));
      });
    }

    return new Album(
      name: json['name'],
      artists: Artist.listFromJson(json['artists']),
      images: MusicImage.listFromJson(json['images']),
      tracks: tracks,
      id: json['id'],
      releaseDate: json['release_date'],
      popularity: json['popularity'] is int
          ? json['popularity']
          : int.parse(json['popularity']),
      representation: RepresentationType.full,
    );
  }

  /// Create a simplified album object from json data
  factory Album.fromSimplifiedJson(dynamic json) {
    return new Album(
      name: json['name'],
      artists: Artist.listFromJson(json['artists']),
      images: MusicImage.listFromJson(json['images']),
      id: json['id'],
      representation: RepresentationType.simplified,
    );
  }
}
