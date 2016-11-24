// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modules.email.email_session/email_session.fidl.dart' as es;
import 'package:lib.fidl.dart/bindings.dart';

import 'email_session_doc.dart';

void _log(String msg) {
  print('[Email Session Module] $msg');
}

/// Implementation of EmailSession service
class EmailSessionImpl extends es.EmailSession {
  final es.EmailSessionBinding _binding = new es.EmailSessionBinding();
  final Link _link;
  final EmailSessionDoc _doc;

  /// Constructor, takes active link
  EmailSessionImpl(this._link, this._doc);

  /// Bind this object to the request
  void bind(InterfaceRequest<es.EmailSession> request) {
    _binding.bind(this, request);
    // TODO(alangardner): Make initial calls to email service here.
  }

  @override
  void focusLabel(String folderId) {
    _log('focusLabel($folderId)');
    // TODO(alangardner): Verify the label exists before setting this
    _doc.focusedLabelId = folderId;
    _update();
  }

  @override
  void focusThread(String threadId) {
    _log('focusThread($threadId)');
    // TODO(alangardner): Implement
    _update();
  }

  void _update() {
    _doc.writeToLink(_link);
  }
}
