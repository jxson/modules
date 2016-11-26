// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modular.services.document_store/document.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';

/// Factory method to create an object from a document
typedef dynamic ParseDocument(String docid, Document doc);

/// Callback when this cache is updated
typedef void CacheUpdated(LinkObjectCache cache);

/// Store impelementation that watches a link and constructs and caches objects.
class LinkObjectCache extends LinkWatcher {
  final Link _link;
  final ParseDocument _parser;
  final CacheUpdated _callback;
  final LinkWatcherBinding _binding = new LinkWatcherBinding();
  final Map<String, Document> _currentDocs;
  final Map<String, dynamic> _parsedObjects;

  /// Build a Link store
  LinkObjectCache(this._link, this._parser, this._callback)
      : _currentDocs = <String, Document>{},
        _parsedObjects = <String, dynamic>{} {
    _link.watch(_binding.wrap(this));
    _link.query(this.notify);
  }

  /// Closes the binding
  void close() => _binding.close();

  void _update() {
    // TODO(alangardner): Later parse only the changes
    _parsedObjects.clear();
    _currentDocs.forEach((String docid, Document doc) {
      dynamic object = _parser(docid, doc);
      if (object != null) {
        _parsedObjects[docid] = object;
      }
    });
    _callback(this);
  }

  @override
  void notify(Map<String, Document> docs) {
    _currentDocs.clear();
    _currentDocs.addAll(docs);
    _update();
  }

  /// Get parsed objects by docid
  dynamic operator [](String docid) => _parsedObjects[docid];

  /// All available docids
  Iterable<String> get docids => _parsedObjects.keys;
}
