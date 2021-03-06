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
    _log(' docid: $docid');
    Map<String, Document> map = <String, Document>{docid: doc};
    EmailSessionDoc session = new EmailSessionDoc();

    session.readFromLink(map);

    return session;
  }

  return null;
}

/// Store for viewing email session state
class EmailSessionLinkStore extends Store implements EmailSessionStore {
  LinkObjectCache _cache;
  EmailSessionDoc _doc = new EmailSessionDoc();
  List<Label> _visibleLabels = const <Label>[];
  List<String> _expandedMessageIds = <String>[];

  /// Constructs a new Store to read the email session from the link
  EmailSessionLinkStore(Link link) {
    _cache = new LinkObjectCache(link, _parser, this._onUpdate);
    triggerOnAction(emailSessionToggleMessageExpand, _toggleMessageExpand);
  }

  @override
  void dispose() {
    _cache.close();
    super.dispose();
  }

  void _onUpdate(LinkObjectCache cache) {
    _log('_onUpdate called: $cache');
    EmailSessionDoc doc = cache[EmailSessionDoc.docid];
    if (doc == null) {
      _log('ERROR: null document for some reason.');
      return;
    }
    bool newlyFocusedThread =
        _doc != null && _doc.focusedThreadId != doc.focusedThreadId;
    _doc = doc;
    _visibleLabels =
        new List<Label>.unmodifiable(_doc?.visibleLabels ?? <Label>[]);
    if (newlyFocusedThread) {
      _expandedMessageIds.clear();
      Thread thread = focusedThread;
      if (thread != null && thread.messages.isNotEmpty) {
        _expandedMessageIds.add(thread.messages.last.id);
      }
    }
    trigger();
  }

  @override
  User get user => _doc?.user;

  @override
  List<Label> get visibleLabels => _visibleLabels;

  @override
  Label get focusedLabel => _doc?.focusedLabelId == null
      ? null
      : visibleLabels.firstWhere(
          (Label l) => _doc.focusedLabelId == l.id,
          orElse: () => null,
        );

  @override
  List<Thread> get visibleThreads => _doc?.visibleThreads ?? <Thread>[];

  @override
  Thread get focusedThread => _doc?.focusedThreadId == null
      ? null
      : visibleThreads.firstWhere(
          (Thread t) => _doc.focusedThreadId == t.id,
          orElse: () => null,
        );

  // TODO(alangardner): Implement. This is only a mock.
  @override
  List<Error> get currentErrors => <Error>[];

  @override
  bool get fetchingLabels => _doc?.fetchingLabels ?? false;

  @override
  bool get fetchingThreads => _doc?.fetchingThreads ?? false;

  // NOTE: This is local to each module, and not shared.
  // TODO(alangardner): This should probably be in a separate store.
  @override
  bool messageIsExpanded(Message message) =>
      _expandedMessageIds.contains(message.id);

  void _toggleMessageExpand(Message message) {
    if (_expandedMessageIds.contains(message.id)) {
      _expandedMessageIds.remove(message.id);
    } else {
      _expandedMessageIds.add(message.id);
    }
  }
}
