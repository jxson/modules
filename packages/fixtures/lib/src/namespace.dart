// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


// static String _uuidUser = uuid.v5(Uuid.NAMESPACE_URL, '/users');
const String _basename = 'fuchsia.googlesource.com/fixtures';
Set<String> _namespaces = new Set<String>();

/// Returns a fixtures url namespace for value.
String namespace(String value) {
  String ns = '$_basename/$value';

  if (!_namespaces.add(ns)) {
    throw new StateError('The namespace "$ns" has already been created.');
  }

  return ns;
}
