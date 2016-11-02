// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

/// TODO(jxson): add documentation.
typedef void UriStreamOnData(String uri);
/// TODO(jxson): add documentation.
typedef void UriStreamOnError(Error error);
/// TODO(jxson): add documentation.
typedef void UriStreamOnDone();

/// TODO(jxson): add documentation.
class UriStream extends Stream<String> {
}
