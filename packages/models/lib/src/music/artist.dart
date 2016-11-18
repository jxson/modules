// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'music_image.dart';
import 'representation_type.dart';

/// Represents a Musical Artist
class Artist {
  /// The name of the artist
  final String name;

  /// Images of the artist in various sizes
  final List<MusicImage> images;

  /// List of genres the artist is associated with
  final List<String> genres;

  /// Spotify ID of artist
  final String id;

  /// Representation type of this model
  final RepresentationType representation;

  /// Constructor
  Artist({
    this.name,
    this.images,
    this.genres,
    this.id,
    this.representation: RepresentationType.full,
  });

  /// Create a full artist object from json data
  factory Artist.fromFullJson(dynamic json) {
    // Format list of genres
    List<String> genres = <String>[];
    dynamic genreJson = json['genres'];
    if (genreJson is List<String>) {
      genres = genreJson;
    }

    return new Artist(
      name: json['name'],
      images: MusicImage.listFromJson(json['images']),
      genres: genres,
      id: json['id'],
      representation: RepresentationType.full,
    );
  }

  /// Create a simplified artist object from json data
  factory Artist.fromSimplifiedJson(dynamic json) {
    return new Artist(
      name: json['name'],
      id: json['id'],
      representation: RepresentationType.simplified,
    );
  }

  /// Creates of list of Artist objects from json data
  /// If json data is invalid, a empty list is returned
  static List<Artist> listFromJson(dynamic json) {
    List<Artist> artists = <Artist>[];
    if (json is List<dynamic>) {
      List<dynamic> jsonList = json;
      jsonList.forEach((dynamic artistJson) {
        artists.add(new Artist.fromSimplifiedJson(artistJson));
      });
    }
    return artists;
  }
}
