// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:apps.modular.lib.app.dart/app.dart';
import 'package:apps.modular.services.application/service_provider.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modules.email.services/email_service.fidl.dart' as service;
import 'package:apps.modules.email.services/email_session.fidl.dart' as es;
import 'package:lib.fidl.dart/bindings.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';

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
    _log('initialize called');
    _link.get(null, _doc.readFromLink);

    connectToService(emailServices, _email.ctrl);

    _log('calling _email.me()');
    _email.me((service.User user) {
      _log('_email.me() called back $user');

      // ignore: STRONG_MODE_DOWN_CAST_COMPOSITE
      Map<String, dynamic> json = JSON.decode(user.jsonPayload);
      _doc.user = new User.fromJson(json);
      _update();

      _log('calling _email.labels()');
      _email.labels(true, (List<service.Label> labels) {
        _log('_email.labels() called back: $labels');
        _doc.visibleLabels = labels
            .map((service.Label l) =>
                new Label.fromJson(JSON.decode(l.jsonPayload)))
            .toList();
        focusLabel('INBOX');
        _update();
      });
    });
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
    if (labelId != _doc.focusedLabelId) {
      _doc.focusedLabelId = labelId;

      // TODO(alangardner): Paging to allow loading of more than 20
      _doc.fetchingThreads = true;
      _email.threads(labelId, 20, (List<service.Thread> threads) {
        _doc.visibleThreads = threads
            .map((service.Thread t) =>
                new Thread.fromJson(JSON.decode(t.jsonPayload)))
            .toList();
        _doc.fetchingThreads = false;
        _doc.focusedThreadId =
            _doc.visibleThreads.isEmpty ? null : _doc.visibleThreads.first.id;
        _update();
      });

      _update();
    }
  }

  @override
  void focusThread(String threadId) {
    _log('focusThread($threadId)');
    // TODO(youngseokyoon): Verify the thread id exists before setting this
    _doc.focusedThreadId = threadId;
    _update();
  }

  void _update() {
    _log('_update called');
    _doc.writeToLink(_link);
  }
}
