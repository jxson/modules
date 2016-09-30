// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:uuid/uuid.dart';
import 'package:quiver/core.dart';

import 'names.dart';

/// TODO document.
final Uuid uuid = new Uuid();

/// TODO document
class Name {
  static String _root = uuid.v5(Uuid.NAMESPACE_URL, 'fuchsia.googlesource.com/fixtures/names');
  static Random _rng = new Random();
  static bool _toggle = true;

  /// TODO document
  String id;
  /// TODO document
  String value;

  /// TODO document
  Name([this.value]) {
    value ??= generate();
    id = uuid.v5(_root, value);
  }

  /// TODO document
  static String generate() {
    String first;
    int firstIndex;

    if (_toggle) {
      firstIndex = _rng.nextInt(kFirstNamesMale.length);
      first = kFirstNamesMale[firstIndex];
    } else {
      firstIndex = _rng.nextInt(kFirstNamesFemale.length);
      first = kFirstNamesFemale[firstIndex];
    }

    _toggle = !_toggle;

    int lastIndex = _rng.nextInt(kSurnames.length);
    String last = kSurnames[lastIndex];

    return '$first $last';
  }

  // The created Set is a plain LinkedHashSet. As such, it considers elements that a
  // re equal (using ==) to be indistinguishable, and requires them to have a com
  // patible Object.hashCode implementation.
  @override
  bool operator ==(Object o) => o is Name && o.id == id;

  @override
  int get hashCode => hash2(id.hashCode, value.hashCode);

  @override
  String toString() {
    return value;
  }
}
