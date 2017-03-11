// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:application.lib.app.dart/app.dart';
import 'package:application.services/service_provider.fidl.dart';
import 'package:apps.email.services/email_content_provider.fidl.dart' as ecp;
import 'package:apps.email.services/email_session.fidl.dart' as es;
import 'package:apps.modular.services.agent.agent_controller/agent_controller.fidl.dart';
import 'package:apps.modular.services.component/component_context.fidl.dart';
import 'package:apps.modular.services.component/message_queue.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:lib.fidl.dart/bindings.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';

import 'email_session_doc.dart';

void _log(String msg) {
  print('[email_session:SessionImpl] $msg');
}

/// Implementation of EmailSession service.
/// This service talks to the [EmailContentProvider] agent to fetch email and
/// listen for new email. It communicates email content updates to other modules
/// over a [Link].
class EmailSessionImpl extends es.EmailSession {
  final String _kContentProviderAgentUrl =
      'file:///system/apps/email_content_provider';

  final String _storyId;

  final List<es.EmailSessionBinding> _bindings = <es.EmailSessionBinding>[];
  final Link _link;
  final EmailSessionDoc _doc;
  final ComponentContextProxy _componentContext;

  // TODO(youngseokyoon): add all the necessary email service interfaces.
  ecp.EmailContentProviderProxy _emailProvider =
      new ecp.EmailContentProviderProxy();
  AgentControllerProxy _emailAgentController = new AgentControllerProxy();
  MessageQueueProxy _notificationQueue = new MessageQueueProxy();

  /// Constructor, takes active link
  EmailSessionImpl(
      this._storyId, this._link, this._doc, this._componentContext);

  /// Bind this object to the request
  void bind(InterfaceRequest<es.EmailSession> request) {
    _bindings.add(new es.EmailSessionBinding()..bind(this, request));
  }

  /// Initializes the email session.
  ///
  /// Connects to necessary email services, and fetches the initial data.
  void initialize() {
    _log('initialize called');
    _link.get(null, _doc.readFromLink);

    /// Connect to the EmailContentProvider agent and get the
    /// [EmailContentProvider] service.
    ServiceProviderProxy incomingServices = new ServiceProviderProxy();
    _componentContext.connectToAgent(_kContentProviderAgentUrl,
        incomingServices.ctrl.request(), _emailAgentController.ctrl.request());
    _log('connecting to email provider..');
    connectToService(incomingServices, _emailProvider.ctrl);
    incomingServices.ctrl.close();

    // Setup a message queue; we receive email updates on this queue.
    _componentContext.obtainMessageQueue(
        'EmailNotifications', _notificationQueue.ctrl.request());
    // This will only receive 1 update. We must call this again to receive
    // further updates.
    _notificationQueue.receive(_onEmailNotification);

    // Sign up for email updates; provide the message queue to receive updates
    // on.
    _notificationQueue.getToken((String token) {
      _emailProvider.registerForUpdates(_storyId, token);
    });

    _log('calling _email.me()');
    _emailProvider.me((ecp.User user) {
      _log('_email.me() called back $user');

      // ignore: STRONG_MODE_DOWN_CAST_COMPOSITE
      Map<String, dynamic> json = JSON.decode(user.jsonPayload);
      _doc.user = new User.fromJson(json);
      _update();

      _log('calling _emailProvider.labels()');
      _emailProvider.labels((List<ecp.Label> labels) {
        _log('_email.labels() called back: $labels');
        _doc.visibleLabels = labels
            .map(
                (ecp.Label l) => new Label.fromJson(JSON.decode(l.jsonPayload)))
            .toList();
        focusLabel('INBOX');
        _update();
      });
    });
  }

  void _onEmailNotification(String message) {
    _log('new email notification: $message');

    // trigger updating the email view.
    _doc.fetchingThreads = true;
    _emailProvider.threads('INBOX', 20, (List<ecp.Thread> threads) {
      _doc.visibleThreads = threads
          .map(
              (ecp.Thread t) => new Thread.fromJson(JSON.decode(t.jsonPayload)))
          .toList();
      _doc.fetchingThreads = false;
      _update();

      // Continue to receive more updates.
      _notificationQueue.receive(_onEmailNotification);
    });
  }

  /// Closes the bindings.
  void close() {
    _emailProvider.ctrl.close();
    _bindings.forEach((es.EmailSessionBinding binding) => binding.close());
    _emailAgentController.ctrl.close();
    _emailProvider.ctrl.close();
  }

  @override
  void focusLabel(String labelId) {
    _log('focusLabel($labelId)');
    // TODO(alangardner): Verify the label exists before setting this
    if (labelId != _doc.focusedLabelId) {
      _doc.focusedLabelId = labelId;

      // TODO(alangardner): Paging to allow loading of more than 20
      _doc.fetchingThreads = true;
      _emailProvider.threads(labelId, 20, (List<ecp.Thread> threads) {
        _doc.visibleThreads = threads
            .map((ecp.Thread t) =>
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
