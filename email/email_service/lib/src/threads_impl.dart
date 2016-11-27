// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:lib.fidl.dart/bindings.dart' as bindings;
import 'package:email_api/email_api.dart';
import 'package:models/email.dart';

import '../fidls.dart' as fidl;
import 'api.dart';

/// Implementation for email_service.
class ThreadsImpl extends fidl.Threads {
  final fidl.ThreadsBinding _binding = new fidl.ThreadsBinding();

  /// Binds this implementation to the incoming [InterfaceRequest].
  ///
  /// This should only be called once. In other words, a new [ThreadsImpl]
  /// object needs to be created per interface request.
  void bind(bindings.InterfaceRequest<fidl.Threads> request) {
    _binding.bind(this, request);
  }

  @override
  Future<Null> list(
      String labelId,
      int max,
      void callback(
    List<fidl.Thread> threads,
  )) async {
    EmailAPI api = await API.get();
    List<Thread> threads = await api.threads(
      labelId: labelId,
      max: max,
    );

    List<fidl.Thread> results = threads.map((Thread thread) {
      String payload = JSON.encode(thread);
      return new fidl.Thread.init(
        thread.id,
        payload,
      );
    }).toList();

    callback(results);

    return null;
  }
}
