// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show JSON;

import 'package:flutter/http.dart' as http;
import 'package:models/music.dart';

const String _kApiBaseUrl = 'api.spotify.com';

/// Client to retrieve data for Music
class MusicClient {
  /// Retrieves given artist based on id
  static Future<Artist> getArtistById(String id) async {
    Uri uri = new Uri.https(_kApiBaseUrl, '/v1/artists/$id');
    http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      return null;
    }
    return new Artist.fromFullJson(JSON.decode(response.body));
  }

  /// Retieves related artists for given artist id
  static Future<List<Artist>> getRelatedArtists(String id) async {
    Uri uri = new Uri.https(_kApiBaseUrl, '/v1/artists/$id/related-artists');
    http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      return null;
    }
    dynamic jsonData = JSON.decode(response.body);
    List<Artist> artists = <Artist>[];
    if (jsonData['artists'] is List<dynamic>) {
      jsonData['artists'].forEach((dynamic artistJson) {
        artists.add(new Artist.fromFullJson(artistJson));
      });
    }
    return artists;
  }

  /// Retrieves the given album based on id
  static Future<Album> getAlbumById(String id) async {
    Uri uri = new Uri.https(_kApiBaseUrl, '/v1/albums/$id');
    http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      return null;
    }
    return new Album.fromFullJson(JSON.decode(response.body));
  }

  /// Retreives albums for given artist id
  static Future<List<Album>> getAlbumsForArtist(String id) async {
    Uri uri = new Uri.https(_kApiBaseUrl, '/v1/artists/$id/albums ');
    http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      return null;
    }
    dynamic jsonData = JSON.decode(response.body);
    List<Album> albums = <Album>[];
    if (jsonData['items'] is List<dynamic>) {
      jsonData['items'].forEach((dynamic albumJson) {
        albums.add(new Album.fromSimplifiedJson(albumJson));
      });
    }
    return albums;
  }
}
