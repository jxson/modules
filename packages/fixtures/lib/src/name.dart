// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:uuid/uuid.dart';
import 'package:quiver/core.dart';

import 'names.dart';
import 'namespace.dart';

final Uuid _uuid = new Uuid();

/// Used by Fixtures for creating names and tracking thier uniqueness.
///
/// A [Name] can be randomly generated or created with an explicit string
/// value.
///
/// When a new [Name] is "generated" it is derieved from a random first name,
/// alternating between values from [kFirstNamesFemale], and
/// [kFirstNamesMale],  a random last name from [kSurnames] is then appended.
///
/// Uniqueness can be verified using the [id] which is a
/// [UUID](http://www.ietf.org/rfc/rfc4122.txt) V5 and hashed off the [Name]'s
/// [value]. The equality operator [==] and [hashCode] have been defined in a
/// way that makes checking uniqueness on [Name] objects arbitrary. For
/// example, two [Name] instances with the same [value] will always have
/// identical [id] values and will pass equality checks. This ensures
/// compatibility with Dart core classes like [Set].
class Name {
  static String _root = _uuid.v5(Uuid.NAMESPACE_URL, namespace('names'));
  static Random _rng = new Random();
  static bool _toggle = true;

  /// The [id] of this [Name]. This is a string UUID derived from hashing the
  /// String [value] of the [Name].
  String id;

  /// The string [value] of the [Name].
  String value;

  /// Create a [Name] instance.
  ///
  /// Specify a specific [Name] [value].
  ///
  ///     Name bob = new Name('Bob');
  ///
  /// Generate a random [Name].
  ///
  ///     Name name = new Name();
  ///
  /// Random names will have a [value] set to something like "Kathleen Gonzales" or "Andrew Johnson". A unique [Name] [value] is not a garuntee of this constructor.
  Name([this.value]) {
    value ??= generate();
    id = _uuid.v5(_root, value);
  }

  /// Generate a random String name.
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

  @override
  bool operator ==(Object o) => o is Name && o.id == id;

  @override
  int get hashCode => hash2(id.hashCode, value.hashCode);

  @override
  String toString() {
    return value;
  }
}
