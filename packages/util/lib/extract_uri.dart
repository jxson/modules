// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Extract a [Set] of unique URIs from a string.
///
Set<Uri> extractURI(String string) {
  String pattern = r'(?:https?)(?:\S+)';
  RegExp exp = new RegExp(pattern, multiLine: false, caseSensitive: false);
  Iterable<Match> matches = exp.allMatches(string);

  return matches.map(_mapper);
}

Uri _mapper(Match match) {
  String url = match.group(0);
  return Uri.parse(url);
}
