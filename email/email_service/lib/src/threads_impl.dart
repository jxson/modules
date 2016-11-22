// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modules.email.email_service/threads.fidl.dart' as es;
import 'package:lib.fidl.dart/bindings.dart';

/// Implementation for email_service.
class ThreadsImpl extends es.Threads {
  final es.ThreadsBinding _binding = new es.ThreadsBinding();

  /// Binds this implementation to the incoming [InterfaceRequest].
  ///
  /// This should only be called once. In other words, a new [ThreadsImpl]
  /// object needs to be created per interface request.
  void bind(InterfaceRequest<es.Threads> request) {
    _binding.bind(this, request);
  }

  @override
  void inbox(int max, void callback(List<es.Thread> threads)) {
    es.Thread thread = new es.Thread();
    thread.id = 'thread-example';
    List<es.Thread> threads = <es.Thread>[thread];
    callback(threads);
  }
}
