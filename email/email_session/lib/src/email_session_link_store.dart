// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modular.services.document_store/document.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'link_object_cache.dart';

void _log(String msg) {
  print('[email_session] $msg');
}

dynamic _parser(String docid, Document doc) {
  _log('Parsing document $docid');
  if (docid == 'docid') {
    return doc.properties['max'].intValue;
  }
  return null;
}

/// Store for viewing email session state
class EmailSessionLinkStore extends Store {
  LinkObjectCache _cache;

  /// Constructs a new Store to read the email session from the link
  EmailSessionLinkStore(Link link) {
    _cache = new LinkObjectCache(link, _parser, this._onUpdate);
  }

  void _onUpdate(LinkObjectCache cache) {
    trigger();
  }

  /// Temporary fake variable for proof of concept
  int get fake => _cache['docid'];
}
