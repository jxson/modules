// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:models/email.dart';

/// Common Type Definitions

/// Callback function signature for an action on a message
typedef void MessageActionCallback(Message message);

/// Callback function signature for an action on a thread
typedef void ThreadActionCallback(Thread thread);

/// Callback function signature for an action on a folder
typedef void FolderActionCallback(Folder folder);
