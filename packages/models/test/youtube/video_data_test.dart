// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:models/youtube.dart';
import 'package:test/test.dart';

void main() {
  test('fromJson() constructor with json data where ID is in json["id"]', () {
    Map<String, dynamic> json = <String, dynamic>{
      'id': 'video1',
      'snippet': <String, String>{
        'title': 'A cool video',
        'description': 'A description',
        'publishedAt': '2014-01-13T22:17:13.000Z',
        'channelTitle': 'My channel'
      },
    };
    VideoData videoData = new VideoData.fromJson(json);
    expect(videoData.id, 'video1');
    expect(videoData.title, 'A cool video');
    expect(videoData.description, 'A description');
    expect(videoData.channelTitle, 'My channel');
  });
  test(
      'fromJson() constructor with json data where ID is in json["id"]["videoId"]',
      () {
    Map<String, dynamic> json = <String, dynamic>{
      'id': <String, String>{
        'videoId': 'video1',
      },
      'snippet': <String, String>{
        'title': 'A cool video',
        'description': 'A description',
        'publishedAt': '2014-01-13T22:17:13.000Z',
        'channelTitle': 'My channel'
      },
    };
    VideoData videoData = new VideoData.fromJson(json);
    expect(videoData.id, 'video1');
    expect(videoData.title, 'A cool video');
    expect(videoData.description, 'A description');
    expect(videoData.channelTitle, 'My channel');
  });
  test('fromJson() constructor with specified json["statistics"', () {
    Map<String, dynamic> json = <String, dynamic>{
      'id': 'video1',
      'snippet': <String, String>{
        'title': 'A cool video',
        'description': 'A description',
        'publishedAt': '2014-01-13T22:17:13.000Z',
        'channelTitle': 'My channel'
      },
      'statistics': <String, String>{
        'viewCount': '10',
        'likeCount': '6',
        'dislikeCount': '4',
      }
    };
    VideoData videoData = new VideoData.fromJson(json);
    expect(videoData.id, 'video1');
    expect(videoData.title, 'A cool video');
    expect(videoData.description, 'A description');
    expect(videoData.channelTitle, 'My channel');
    expect(videoData.viewCount, 10);
    expect(videoData.likeCount, 6);
    expect(videoData.dislikeCount, 4);
  });
}
