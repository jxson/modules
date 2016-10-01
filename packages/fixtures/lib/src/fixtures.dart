// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:models/user/user.dart';
import 'package:uuid/uuid.dart';

import 'namespace.dart';
import 'name.dart';

final Uuid _uuid = new Uuid();

/// The operation was not allowed by the current state of the [Fixtures]
/// instance.
class FixturesError extends StateError {
  /// Create a [FixturesError].
  ///
  ///     FixturesError err = new FixturesError('Something bad happened');
  ///
  FixturesError(String msg) : super(msg);
}

/// Defines generators for objects to be used in UI mocks and tests.
///
/// Generators are, and should be defined as methods of [Fixtures] and return
/// instances of objects that attempt to be random and unique. Uniqueness is
/// only guaranteed up to the set uniqueness [threshold].
///
/// New instances can used to reset sequences ([sequence]) and generators like
/// [name] and [user].
///
/// The objects returned from [Fixtures] methods are not Stubs, or Mocks. They
/// are actual instances of their return types.
class Fixtures {
  Set<Name> _names = new Set<Name>();
  Map<String, int> _sequences = new Map<String, int>();
    static String _uuidUser = _uuid.v5(Uuid.NAMESPACE_URL, namespace('users'));

  /// Uniqueness [threshold].
  ///
  /// Generators like [name] use the [threshold] to limit the total unique
  /// values they produce. When the threshold is reached a [FixturesError]
  /// will be thrown.
  int threshold;

  /// Create an instance of [Fixtures].
  ///
  ///     Fixtures fixtures = new Fixtures();
  ///
  /// If you need a higher set of unique values from generators (like
  /// [name]) over the default [threshold] it can be optionally set:
  ///
  ///     Fixtures fixtures = new Fixtures(threshold: 5000);
  ///
  Fixtures({ this.threshold }) {
    threshold ??= 1000;
  }

  /// Retrieve a namespaced [sequence].
  ///
  /// The [sequence] [int] returned for the namespace key will be increased
  /// incrementally for every call.
  ///
  /// The first time a sequence is called it will return an `int` value of
  ///  `1`.
  ///
  ///     // The sequence value will equal `1`.
  ///     int sequence = fixtures.sequence('email');
  ///
  /// Subsequent calls will return a value that is incremented above the
  /// previously returned value.
  ///
  ///     // The sequence value will equal `2`.
  ///     int sequence = fixtures.sequence('email');
  ///
  int sequence(String key) {
    _sequences[key] ??= 0;
    return ++_sequences[key];
  }

  /// Generate a [Name].
  ///
  /// When called without the optional value, a new random [Name] will be
  /// returned.
  ///
  ///     // The name will have value like "Brenda Wade".
  ///     Name name = fixtures.name();
  ///
  /// [Fixtures] instances track subsequent calls to [name] to guarantee
  /// unique random [Name] values, even against ones that have an explicitly
  /// set value. Additional calls for explicit names will not be counted
  /// against the [threshold] after the first time.
  ///
  /// Generates a Name object with the value 'Bob'.
  ///
  ///     Name bob = fixtures.name('Jason Campbell');
  ///
  /// Generates a [Name] object with a random value. The
  /// random [Name] will never have the value "Jason Campbell".
  ///
  ///     Name name = fixtures.name();
  ///
  /// Throws [FixturesError] if the [threshold] for unique names is met.
  Name name([String value]) {
    Name name;

    if (value != null) {
      name = new Name(value);
      _names.add(name);
    } else {
      name = new Name();

      while (!_names.add(name)) {
        name = new Name();
      }
    }

    if (_names.length == threshold+1) {
      String message = 'Threshold for Names exceeded, $threshold unique'
        'names have been generated.';
      throw new FixturesError(message);
    }

    return name;
  }

  /// Generate a [User].
  ///
  /// Generate a random [User]:
  ///
  ///     User user = fixtures.user();
  ///
  /// Generate a [User] with a specific name:
  ///
  ///     User user = fixtures.user(name: 'Alice');
  ///
  User user({ String name }) {
    name ??= new Name().toString();

    int seq = sequence('email');
    String email = 'user-$seq@example.org';
    String id = _uuid.v5(_uuidUser, email);
    String avatar = 'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg';
    return new User(id: id, name: name, email: email, locale: 'en', picture: avatar);
  }
}
