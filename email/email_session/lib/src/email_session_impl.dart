// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modular.services.document_store/document.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modules.email.email_session/email_session.fidl.dart'
    as es;
import 'package:lib.fidl.dart/bindings.dart';

void _log(String msg) {
  print('[Email Session Module] $msg');
}

/// TODO
class EmailSessionImpl extends es.EmailSession {
  final es.EmailSessionBinding _binding = new es.EmailSessionBinding();
  final Link _link;

  /// TODO
  EmailSessionImpl(this._link);

  /// TODO
  void bind(InterfaceRequest<es.EmailSession> request) {
    _binding.bind(this, request);
  }

  @override
  void fakeAction(int max) {
    _log('Received max: $max');
    _link.setAllDocuments(<String, Document>{
      'docid': new Document.init(
          'docid', <String, Value>{'max': new Value()..intValue = max})
    });
  }
}
