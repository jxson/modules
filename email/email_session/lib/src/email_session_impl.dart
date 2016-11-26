// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:apps.modular.lib.app.dart/app.dart';
import 'package:apps.modular.services.application/service_provider.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modules.email.email_service/threads.fidl.dart' as service;
import 'package:apps.modules.email.email_session/email_session.fidl.dart' as es;
import 'package:lib.fidl.dart/bindings.dart';

import 'email_session_doc.dart';

void _log(String msg) {
  print('[email_session:SessionImpl] $msg');
}

/// Implementation of EmailSession service
class EmailSessionImpl extends es.EmailSession {
  final es.EmailSessionBinding _binding = new es.EmailSessionBinding();
  final Link _link;
  final EmailSessionDoc _doc;

  // TODO(youngseokyoon): add all the necessary email service interfaces.
  service.ThreadsProxy _threads = new service.ThreadsProxy();

  /// Constructor, takes active link
  EmailSessionImpl(this._link, this._doc);

  /// Bind this object to the request
  void bind(InterfaceRequest<es.EmailSession> request) {
    _binding.bind(this, request);
  }

  /// Initializes the email session.
  ///
  /// Connects to necessary email services, and fetches the initial data.
  void initialize(ServiceProvider emailServices) {
    connectToService(emailServices, _threads.ctrl);

    // TODO(youngseokyoon): make a call to email_service to fetch initial data.
  }

  /// Closes the bindings.
  void close() {
    _threads.ctrl.close();
    _binding.close();
  }

  @override
  void focusLabel(String folderId) {
    _log('focusLabel($folderId)');
    // TODO(alangardner): Verify the label exists before setting this
    _doc.focusedLabelId = folderId;

    // TODO(youngseokyoon): make a call to email_service here to fetch relevant
    // threads. For now, just fake it with a timer.
    _doc.fetchingThreads = true;
    new Timer(new Duration(seconds: 3), () {
      _doc.fetchingThreads = false;
      _update();
    });

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
