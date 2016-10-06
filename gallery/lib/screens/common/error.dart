// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// A simple screen for showing an error message.
class ErrorScreen extends StatelessWidget {
  /// The error message.
  final String message;

  /// Creates a new instance of [ErrorScreen] with the given error message.
  ErrorScreen(this.message);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Error Occurred')),
      body: new Text(message),
    );
  }
}
