// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:apps.modules.email.email_service/email.fidl.dart' as es;
import 'package:email_api/email_api.dart';
import 'package:fixtures/fixtures.dart';
import 'package:lib.fidl.dart/bindings.dart' as bindings;
import 'package:models/email.dart';
import 'package:models/user.dart';

import 'api.dart';

void _log(String msg) {
  print('[email_service] $msg');
}

/// Implementation for email_service.
class EmailServiceImpl extends es.EmailService {
  // HACK(alangardner): Used for backup testing if network calls fail
  final Fixtures fixtures = new Fixtures();

  final es.EmailServiceBinding _binding = new es.EmailServiceBinding();

  /// Binds this implementation to the incoming [bindings.InterfaceRequest].
  ///
  /// This should only be called once. In other words, a new [EmailServiceImpl]
  /// object needs to be created per interface request.
  void bind(bindings.InterfaceRequest<es.EmailService> request) {
    _binding.bind(this, request);
  }

  /// Close the binding
  void close() => _binding.close();

  @override
  Future<Null> me(
    void callback(es.User user),
  ) async {
    _log('* me() called');
    User me;

    try {
      EmailAPI api = await API.get();
      me = await api.me();
    } on SocketException catch (e) {
      _log('SocketException: $e');
      me = fixtures.me();
    } catch (e) {
      _log('BAD ERROR: $e');
      me = fixtures.me();
    }

    String payload = JSON.encode(me);
    es.User result = new es.User.init(
      me.id,
      payload,
    );

    if (callback == null) {
      _log('** callback is null');
    }

    _log('* me() calling back');
    callback(result);
  }

  @override
  Future<Null> labels(
    bool all,
    void callback(List<es.Label> labels),
  ) async {
    _log('* labels() called');
    List<Label> labels;

    try {
      EmailAPI api = await API.get();
      labels = await api.labels();
    } on SocketException catch (e) {
      _log('SocketException: $e');
      labels = fixtures.labels();
    } catch (e) {
      _log('BAD ERROR: $e');
      labels = fixtures.labels();
    }

    List<es.Label> results = labels.map((Label label) {
      String payload = JSON.encode(label);
      return new es.Label.init(
        label.id,
        payload,
      );
    }).toList();

    _log('* labels() calling back');
    callback(results);
  }

  @override
  Future<Null> threads(
    String labelId,
    int max,
    void callback(List<es.Thread> threads),
  ) async {
    _log('* threads() called');
    List<Thread> threads;

    try {
      EmailAPI api = await API.get();
      threads = await api.threads(
        labelId: labelId,
        max: max,
      );
    } on SocketException catch (e) {
      _log('SocketException: $e');
      threads = fixtures.threads(4);
    } catch (e) {
      _log('BAD ERROR: $e');
      threads = fixtures.threads(4);
    }

    List<es.Thread> results = threads.map((Thread thread) {
      String payload = JSON.encode(thread);
      return new es.Thread.init(
        thread.id,
        payload,
      );
    }).toList();

    _log('* threads() calling back');
    callback(results);
  }
}
