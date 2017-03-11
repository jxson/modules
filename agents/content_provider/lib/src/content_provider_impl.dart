// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:apps.email.services/email_content_provider.fidl.dart' as ecp;
import 'package:apps.maxwell.services.suggestion/proposal.fidl.dart';
import 'package:apps.maxwell.services.suggestion/proposal_publisher.fidl.dart';
import 'package:apps.maxwell.services.suggestion/suggestion_display.fidl.dart';
import 'package:apps.modular.services.component/component_context.fidl.dart';
import 'package:apps.modular.services.component/message_queue.fidl.dart';
import 'package:email_api/email_api.dart';
import 'package:lib.fidl.dart/bindings.dart' as bindings;
import 'package:models/email.dart';
import 'package:models/user.dart';

import 'api.dart';

void _log(String msg) {
  print('[email_content_provider] $msg');
}

/// Period at which we check for new email.
final Duration kRefreshPeriodSecs = new Duration(minutes: 1);

/// This datastructure is used to keep a record of subscribers that want email
/// updates. This is constructed when
/// [EmailContentProviderImpl.registerForUpdates] is called.
class NotificationSubscriber {
  /// The [storyId] to focus when new email arrives.
  String storyId;

  /// The [MessageSender] we will send a message to when new emails arrive. The
  /// interested module will listen for updates by receiving on their end of the
  /// MessageQueue.
  MessageSenderProxy senderProxy;

  /// Constructor.
  NotificationSubscriber(this.storyId, this.senderProxy);
}

/// Implementation for email_service.
class EmailContentProviderImpl extends ecp.EmailContentProvider {
  final List<ecp.EmailContentProviderBinding> _bindings =
      new List<ecp.EmailContentProviderBinding>();

  final ComponentContextProxy _componentContext;
  final ProposalPublisherProxy _proposalPublisher;

  // We keep our email state here in these completers, which act as barriers
  // for setting and getting state. If any callers try to await for this state
  // before it is ready, they will continue to await until it is ready. After
  // that unchanged state can be awaited repeatedly and it is fine.
  Completer<ecp.User> _user = new Completer<ecp.User>();
  Completer<List<ecp.Label>> _labels = new Completer<List<ecp.Label>>();
  // label id -> list of threads
  Map<String, Completer<List<Thread>>> _labelToThreads =
      new Map<String, Completer<List<Thread>>>();

  Map<String, NotificationSubscriber> _notificationSubscribers =
      new Map<String, NotificationSubscriber>();

  Timer _refreshTimer;

  /// Constructor.
  EmailContentProviderImpl(this._componentContext, this._proposalPublisher);

  /// Binds this implementation to the incoming [bindings.InterfaceRequest].
  ///
  /// This should only be called once. In other words, a new
  /// [EmailContentProviderImpl] object needs to be created per interface
  /// request.
  void addBinding(bindings.InterfaceRequest<ecp.EmailContentProvider> request) {
    _log('New client for EmailContentProvider');
    _bindings.add(new ecp.EmailContentProviderBinding()..bind(this, request));
  }

  /// Close all our bindings; called by our owner during termination.
  void close() =>
      _bindings.forEach((ecp.EmailContentProviderBinding b) => b.close());

  /// Preloads the results for [me] and [labels]. Threads for each label and
  /// loaded on demand. Kicks of periodic email updates.
  Future<Null> init() async {
    EmailAPI _api = await API.get();

    User me = await _api.me();
    List<Label> labels = await _api.labels();

    /// load the user information; served by me()
    String payload = JSON.encode(me);
    _user.complete(new ecp.User.init(me.id, payload));

    /// load the labels; served by labels()
    _labels.complete(labels.map((Label label) {
      String payload = JSON.encode(label);
      return new ecp.Label.init(label.id, payload);
    }).toList());

    _refreshTimer = new Timer(kRefreshPeriodSecs, this.onRefresh);
  }

  /// Called every [kRefreshPeriodSecs] to refresh labels. It will check for new
  /// email for each loaded labelId, and if they exist, send a notification to
  /// all interested parties (who subscribed using [registerForUpdates]).
  Future<Null> onRefresh() async {
    _log('Refreshing email..');
    EmailAPI _api = await API.get();

    for (String labelId in _labelToThreads.keys) {
      int numEmail = await _api.fetchNewEmail(labelId: labelId);
      if (numEmail > 0) {
        await _fetchThreads(
            labelId, (await _labelToThreads[labelId].future).length);
        _notificationSubscribers.forEach(
            (String messageQueueToken, NotificationSubscriber subscriber) {
          subscriber.senderProxy.send('New Email!');

          Proposal p = new Proposal();
          p.id = 'EmailContentProvider';
          p.onSelected = <Action>[new Action()];
          p.onSelected[0].focusStory = new FocusStory.init(subscriber.storyId);
          // TODO(vardhan): Revisit display params.
          p.display = new SuggestionDisplay.init(
              'You have mail',
              '...',
              '......',
              0xffffffff,
              SuggestionImageType.person,
              new List<String>(),
              '');

          _proposalPublisher.propose(p);
        });
      }
    }
    _refreshTimer = new Timer(kRefreshPeriodSecs, this.onRefresh);
  }

  Future<Null> _fetchThreads(String labelId, int max) async {
    _labelToThreads[labelId] = new Completer<List<Thread>>();
    EmailAPI _api = await API.get();

    List<Thread> threads = await _api.threads(labelId: labelId, max: max);

    _log('fetched ${threads.length} emails.');

    _labelToThreads[labelId].complete(threads);
  }

  @override
  Future<Null> me(void callback(ecp.User user)) async {
    _log('* me() called');
    callback(await _user.future);
    _log('* me() called back');
  }

  @override
  Future<Null> labels(void callback(List<ecp.Label> labels)) async {
    _log('* labels() called');
    callback(await _labels.future);
    _log('* labels() called back');
  }

  @override
  Future<Null> threads(
      String labelId, int max, void callback(List<ecp.Thread> threads)) async {
    _log('* threads() called');

    if (_labelToThreads[labelId] == null) {
      await _fetchThreads(labelId, max);
    }

    List<ecp.Thread> retval =
        (await _labelToThreads[labelId].future).map((Thread thread) {
      String payload = JSON.encode(thread);
      return new ecp.Thread.init(thread.id, payload);
    }).toList();

    callback(retval);
    _log('* threads() called back');
  }

  @override
  void registerForUpdates(String storyId, String messageQueueToken) {
    _log('* registerForUpdates($storyId, $messageQueueToken) called');

    // already exists?
    if (_notificationSubscribers.containsKey(messageQueueToken)) {
      _log('$messageQueueToken already subscribed to notifications');
      return;
    }

    NotificationSubscriber subscriber =
        new NotificationSubscriber(storyId, new MessageSenderProxy());
    _notificationSubscribers[messageQueueToken] = subscriber;
    _componentContext.getMessageSender(
        messageQueueToken, subscriber.senderProxy.ctrl.request());
  }
}
