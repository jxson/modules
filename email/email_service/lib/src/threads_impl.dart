// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.modules.email.email_service/threads.fidl.dart' as fidl;

/// Implementation for email_service.
class ThreadsImpl extends fidl.Threads {
  @override
  void inbox(int max, void callback(List<fidl.Thread> threads)) {
    fidl.Thread thread = new fidl.Thread();
    thread.id = 'thread-example';
    List<fidl.Thread> threads = <fidl.Thread>[thread];
    callback(threads);
  }
}
