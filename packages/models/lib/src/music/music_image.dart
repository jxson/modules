// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Represents a Spotify Image Object
class MusicImage {
  /// Height of image
  final double height;

  /// Widget of image
  final double width;

  /// Source URL of image
  final String url;

  /// Constructor
  MusicImage({
    this.height,
    this.width,
    this.url,
  });

  /// Creates a MusicImage object from json data
  factory MusicImage.fromJson(dynamic json) {
    String url = json['url'];
    url = url.replaceFirst('https', 'http');
    return new MusicImage(
      height: json['height'].roundToDouble(),
      width: json['width'].roundToDouble(),
      url: url,
    );
  }

  /// Creates of list of MusicImage objects from json data
  /// If json data is invalid, a empty list is returned
  static List<MusicImage> listFromJson(dynamic json) {
    List<MusicImage> images = <MusicImage>[];
    if (json is List<dynamic>) {
      List<dynamic> jsonList = json;
      jsonList.forEach((dynamic imageJson) {
        images.add(new MusicImage.fromJson(imageJson));
      });
    }
    return images;
  }
}
