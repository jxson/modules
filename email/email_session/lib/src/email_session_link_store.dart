// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modular.services.document_store/document.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:email_session_store/email_session_store.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';

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
class EmailSessionLinkStore extends Store implements EmailSessionStore {
  LinkObjectCache _cache;

  /// Constructs a new Store to read the email session from the link
  EmailSessionLinkStore(Link link) {
    _cache = new LinkObjectCache(link, _parser, this._onUpdate);
  }

  void _onUpdate(LinkObjectCache cache) {
    trigger();
  }

  // TODO(alangardner): Implement
  @override
  User get user => new User(
        name: 'Coco Yang',
        email: 'littlePuppyCoco@puppy.cute',
      );

  // TODO(alangardner): Implement
  @override
  List<Label> get visibleLabels => <Label>[
        new Label(
          id: 'INBOX',
          name: 'Inbox',
          unread: 10,
          type: 'system',
        ),
        new Label(
          id: 'STARRED',
          name: 'Starred',
          unread: 5,
          type: 'system',
        ),
        new Label(
          id: 'DRAFT',
          name: 'Starred',
          unread: 0,
          type: 'system',
        ),
        new Label(
          id: 'TRASH',
          name: 'Trash',
          unread: 0,
          type: 'system',
        ),
        new Label(
          id: 'TODO',
          name: 'Todo',
          unread: 2,
          type: 'user',
        ),
        new Label(
          id: 'COMPLETED',
          name: 'Completed',
          unread: 2,
          type: 'user',
        ),
        new Label(
          id: 'JIRA',
          name: 'Jira',
          unread: 0,
          type: 'user',
        ),
        new Label(
          id: 'GERRIT',
          name: 'Gerrit',
          unread: 0,
          type: 'user',
        ),
      ];

  // TODO(alangardner): Implement
  @override
  Label get focusedLabel => new Label(
        id: 'INBOX',
        name: 'Inbox',
        unread: 10,
        type: 'system',
      );

  // TODO(alangardner): Implement
  @override
  List<Thread> get visibleThreads => <Thread>[
        new MockThread(id: '1'),
        new MockThread(id: '2'),
        new MockThread(id: '3')
      ];

  // TODO(alangardner): Implement
  @override
  Thread get focusedThread => new MockThread(id: '1');

  // TODO(alangardner): Implement
  @override
  List<Error> get currentErrors => <Error>[];

  // TODO(alangardner): Implement
  @override
  bool get fetchingThreads => false;

  // TODO(alangardner): Implement
  @override
  bool get fetchingLabels => false;

  // TODO(alangardner): Implement
  @override
  bool messageIsExpanded(Message message) => true;
}
