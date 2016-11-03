// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:test/test.dart';
// import 'package:util/uri_scraper.dart';

void main() {
  test('extract_url()', () {
    // text => urls => entities
    // text: Checkout this video! https://www.youtube.com/watch?v=ZAn3JdtSrnY
    // urls: [ https://www.youtube.com/watch?v=ZAn3JdtSrnY ]
    // attachement json: {attachmentId: null, size: ..., data: ...}
    String text = 'Checkout this video! https://www.youtube.com/watch?v=ZAn3JdtSrnY';
    Set<String> uris = extractURI(text);

    expect(uris.contains('https://www.youtube.com/watch?v=ZAn3JdtSrnY'), isTrue );
  });
}

/// TODO(jxson): document.
Set<String> extractURI(String string) {
  RegExp _exp = new RegExp(r'^(?:(?:https?|ftp):\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,}))\.?)(?::\d{2,5})?(?:[/?#]\S*)?$');

  print('=========');
  print('= ${string}');
  print('========= \n');

  Iterable<Match> matches = _exp.allMatches(string);

  print('1 =========');

  for (Match m in matches) {
    String match = m.group(0);
    print(match);
  }

  print('2 =========');

  return new Set<String>();
}
