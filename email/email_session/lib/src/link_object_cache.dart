// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:apps.modular.services.story/link.fidl.dart';

typedef void LinkUpdated(Map<String, dynamic> json);

/// Store implementation that watches a Link and constructs the JSON Map<>.
class LinkWatcherImpl extends LinkWatcher {
  final Link _link;
  final LinkWatcherBinding _binding = new LinkWatcherBinding();
  final LinkUpdated _callback;

  /// Construct a LinkWatcherImpl
  LinkWatcherImpl(this._link, this._callback) {
    _link.watch(_binding.wrap(this));
    _link.get('', this.notify);
  }

  /// Closes the binding
  void close() => _binding.close();

  @override
  void notify(String json) {
    // ignore: STRONG_MODE_DOWN_CAST_COMPOSITE
    Map<String, dynamic> doc = JSON.decode(json);
    _callback(doc);
  }
}
