// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Represents a comment on a Youtube video
class VideoComment {
  /// Display name of comment author
  final String authorDisplayName;

  /// URL of author profile image/avatar
  final String authorProfileImageUrl;

  /// Text of comment
  final String text;

  /// Number of likes given to comment
  final int likeCount;

  /// Number of total replies given to comment
  final int totalReplyCount;

  /// Constructor
  VideoComment({
    this.authorDisplayName,
    this.authorProfileImageUrl,
    this.text,
    this.likeCount,
    this.totalReplyCount,
  });

  /// Constructs [VideoComment] model from Youtube api json data
  factory VideoComment.fromJson(dynamic json) {
    dynamic topLevelSnippet = json['snippet']['topLevelComment']['snippet'];
    // HACK(dayang): Removing non-ascii characters for fuchsia, should place
    // back once Emojis are working
    String authorDisplayName = topLevelSnippet['authorDisplayName'];
    authorDisplayName.replaceAll(new RegExp('[^\\x00-\\x7F]'), '');
    String text = topLevelSnippet['textDisplay'];
    text.replaceAll(new RegExp('[^\\x00-\\x7F]'), '');
    // HACK(dayang): Converted images from HTTPS to HTTP, should remove once
    // SSL is working
    String authorProfileImageUrl = topLevelSnippet['authorProfileImageUrl'];
    authorProfileImageUrl = authorProfileImageUrl.replaceFirst('https', 'http');
    return new VideoComment(
      authorDisplayName: authorDisplayName,
      authorProfileImageUrl: authorProfileImageUrl,
      text: text,
      likeCount: topLevelSnippet['likeCount'],
      totalReplyCount: json['snippet']['totalReplyCount'],
    );
  }
}
