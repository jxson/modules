// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modular.services.document_store/document.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:email_session_store/email_session_store.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';

import 'email_session_doc.dart';
import 'link_object_cache.dart';

void _log(String msg) {
  print('[email_session:LinkStore] $msg');
}

dynamic _parser(String docid, Document doc) {
  _log('Parsing document $docid');
  if (docid == EmailSessionDoc.docid) {
    return new EmailSessionDoc.fromLinkDocument(doc);
  }
  return null;
}

/// Store for viewing email session state
class EmailSessionLinkStore extends Store implements EmailSessionStore {
  LinkObjectCache _cache;
  EmailSessionDoc _doc = new EmailSessionDoc();
  List<Label> _visibleLabels = new List<Label>.unmodifiable(<Label>[]);

  /// Constructs a new Store to read the email session from the link
  EmailSessionLinkStore(Link link) {
    _cache = new LinkObjectCache(link, _parser, this._onUpdate);
  }

  @override
  void dispose() {
    _cache.close();
    super.dispose();
  }

  void _onUpdate(LinkObjectCache cache) {
    _log('_onUpdate call');
    EmailSessionDoc doc = cache[EmailSessionDoc.docid];
    if (_doc == null) {
      _log('ERROR: null document for some reason.');
      return;
    }
    _doc = doc;
    _visibleLabels = new List<Label>.unmodifiable(_doc?.labels ?? <Label>[]);
    trigger();
  }

  // TODO(alangardner): Implement. This is only a mock.
  @override
  User get user => new User(
        name: 'Coco Yang',
        email: 'littlePuppyCoco@puppy.cute',
      );

  @override
  List<Label> get visibleLabels => _visibleLabels;

  @override
  Label get focusedLabel => _doc?.focusedLabelId == null
      ? null
      : visibleLabels.firstWhere((Label f) => _doc.focusedLabelId == f.id,
          orElse: null);

  // TODO(alangardner): Implement. This is only a mock.
  @override
  List<Thread> get visibleThreads => <Thread>[
        new MockThread(id: '1'),
        new MockThread(id: '2'),
        new MockThread(id: '3')
      ];

  // TODO(alangardner): Implement. This is only a mock.
  @override
  Thread get focusedThread => new MockThread(id: '1');

  // TODO(alangardner): Implement. This is only a mock.
  @override
  List<Error> get currentErrors => <Error>[];

  @override
  bool get fetchingLabels => _doc?.fetchingLabels ?? false;

  @override
  bool get fetchingThreads => _doc?.fetchingThreads ?? false;

  // TODO(alangardner): Implement. This is only a mock.
  // TODO(alangardner): This should probably be in a separate store.
  @override
  bool messageIsExpanded(Message message) => true;
}
