// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:apps.modular.lib.app.dart/app.dart';
import 'package:apps.modular.services.application/service_provider.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modules.email.email_service/email.fidl.dart' as service;
import 'package:apps.modules.email.email_session/email_session.fidl.dart' as es;
import 'package:lib.fidl.dart/bindings.dart';
import 'package:models/email.dart';

import 'email_session_doc.dart';

void _log(String msg) {
  print('[email_session:SessionImpl] $msg');
}

/// Implementation of EmailSession service
class EmailSessionImpl extends es.EmailSession {
  final List<es.EmailSessionBinding> _bindings = <es.EmailSessionBinding>[];
  final Link _link;
  final EmailSessionDoc _doc;

  // TODO(youngseokyoon): add all the necessary email service interfaces.
  service.EmailServiceProxy _email = new service.EmailServiceProxy();

  /// Constructor, takes active link
  EmailSessionImpl(this._link, this._doc);

  /// Bind this object to the request
  void bind(InterfaceRequest<es.EmailSession> request) {
    _bindings.add(new es.EmailSessionBinding()..bind(this, request));
  }

  /// Initializes the email session.
  ///
  /// Connects to necessary email services, and fetches the initial data.
  void initialize(ServiceProvider emailServices) {
    connectToService(emailServices, _email.ctrl);

    // TODO(youngseokyoon): make a call to email_service to fetch initial data.
  }

  /// Closes the bindings.
  void close() {
    _email.ctrl.close();
    _bindings.forEach((es.EmailSessionBinding binding) => binding.close());
  }

  @override
  void focusLabel(String labelId) {
    _log('focusLabel($labelId)');
    // TODO(alangardner): Verify the label exists before setting this
    _doc.focusedLabelId = labelId;

    // TODO(youngseokyoon): make a call to email_service here to fetch relevant
    // threads. For now, just fake it with a timer.
    _doc.fetchingThreads = true;

    new Timer(new Duration(milliseconds: 300), () {
      Label currentLabel = _doc.visibleLabels
          .firstWhere((Label l) => l.id == _doc.focusedLabelId);
      _doc.visibleThreads = mockThreads(currentLabel.unread);
      _doc.fetchingThreads = false;
      _update();
    });

    _update();
  }

  @override
  void focusThread(String threadId) {
    _log('focusThread($threadId)');
    // TODO(youngseokyoon): Verify the thread id exists before setting this
    _doc.focusedThreadId = threadId;
    _update();
  }

  void _update() {
    _doc.writeToLink(_link);
  }
}
