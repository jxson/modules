// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modules.email.email_service/service.fidl.dart';

/// Implementation for email_service.
class ThreadsImpl extends Threads {
  @override
  void inbox(int max, void callback(List<Thread> threads)) {
    Thread thread = new Thread();
    thread.id = 'thread-example';
    List<Thread> threads = <Thread>[thread];
    callback(threads);
  }
}
