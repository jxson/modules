// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:models/email.dart';

/// Defines the APIs for an email service.
abstract class EmailClient {
  /// Gets the email [Thread]s.
  Future<GetThreadsResponse> getThreads({dynamic args});

  /// Gets the email [Thread] specified by the string id.
  Future<Thread> getThread(String threadId, {dynamic args});
}

/// Response object for the getThreads method.
/// Contains the email [Thread]s, and other vendor-specific metadata.
abstract class GetThreadsResponse {
  /// The email [Thread]s returned from the server.
  final List<Thread> threads;

  /// Creates an instance of [GetThreadsResponse] object.
  GetThreadsResponse(List<Thread> threads) : threads = threads;
}
