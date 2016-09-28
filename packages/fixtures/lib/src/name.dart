// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:uuid/uuid.dart';

/// TODO document.
final Uuid uuid = new Uuid();

/// TODO document
class Name {
  static String _root = uuid.v5(Uuid.NAMESPACE_URL, 'name.fuchsia.community');

  /// TODO document
  String id;
  String _value;

  /// TODO document
  Name([String value = 'Jason']) {
    // generate name with a factory that checks for repeats.
    _value = value;
    id = uuid.v5(_root, value);

    print('Generated name: $_value');
    print('            id: $id');
  }

  /// TODO document
  bool operator ==(o) => o is Name && o.id == id;

  /// TODO override hashCode: http://pchalin.blogspot.com/2014/04/defining-equality-and-hashcode-for-dart.html

  @override
  String toString() {
    return _value;
  }
}
