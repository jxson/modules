// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:widgets/email.dart';

/// This screen displays an Google Inbox style email editor.
class EmailEditorScreen extends StatefulWidget {
  /// Creates a [EmailEditorScreen] instance.
  EmailEditorScreen({Key key}) : super(key: key);

  @override
  _EmailEditorScreenState createState() => new _EmailEditorScreenState();
}

class _EmailEditorScreenState extends State<EmailEditorScreen> {
  @override
  Widget build(BuildContext context) => new EditorScreen();
}
