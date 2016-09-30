// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// To use the real data using Google APIs, fill in the client id / secret
// values in this map. These values should only be set on your local machine,
// and should not be checked in to the repository.
//
// You can tell git to ignore any local changes to this file by running the
// following command from the repository root:
//
//     git update-index --assume-unchanged gallery/lib/src/config.dart
//

/// Configuration data for the Google APIs.
const Map<String, String> kConfig = const <String, String>{
  /// Client ID for the GoogleAPI project.
  'client_id': null,

  /// Client secret for the GoogleAPI project.
  'client_secret': null,
};
