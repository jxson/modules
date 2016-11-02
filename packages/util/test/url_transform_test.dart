// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:test/test.dart';
import 'package:util/uri_scraper.dart';

void main() {
  test('', () {
    // text => urls => entities
    // text: Checkout this video! https://www.youtube.com/watch?v=ZAn3JdtSrnY
    // urls: [ https://www.youtube.com/watch?v=ZAn3JdtSrnY ]
    // attachement json: {attachmentId: null, size: ..., data: ...}

    List<String> uris = [];
    List<String> text = [
      'Checkout this video! https://www.youtube.com/watch?v=ZAn3JdtSrnY'
    ];

    new Stream.fromIterable(text)
      .transform(new UriScraper())
      // .transform(YouTubeAttacment.fromURI)
      .listen((String uri) {
        uris.add(uri);
      });

    expect(uris.length, equals(1));
    expect(uris[0], equals('https://www.youtube.com/watch?v=ZAn3JdtSrnY'));
  });
}
