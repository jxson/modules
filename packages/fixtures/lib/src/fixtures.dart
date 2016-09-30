// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(jxson): Fixup dir structure so this works.
// import 'package:models/models.dart';
// import 'name.dart';
import 'package:models/user/user.dart';
import 'package:uuid/uuid.dart';

import 'namespace.dart';
import 'name.dart';

/// The operation was not allowed by the current state of the [Fixtures]
/// instance.
class FixturesError extends StateError {
  FixturesError(String msg) : super(msg);
}

/// Defines generators for objects to be used in UI mocks and tests.
///
/// Generators are, and should be defined as methods of [Fixtures] and return
/// instances of objects that attempt to be random and unique. Uniqueness is
/// only garunteed up to the set uniqueness [threshold].
///
/// New instances can used to reset sequences ([sequence]) and generators like
/// [name] and [user].
///
/// The objects returned from [Fixtures] methods are not Stubs, or Mocks. They
/// are actual instances of thier return types.
class Fixtures {
  static Set<Name> _names = new Set<Name>();
  Map<String, int> _sequences = new Map<String, int>();
    static String _uuidUser = uuid.v5(Uuid.NAMESPACE_URL, namespace('users'));

  /// Uniqueness [threshold] for this instance of [Fixtrues].
  ///
  /// Generators like [name] use the [threshold] to limit the total unique
  /// values they produce. When the threshold is reached a [FixturesError]
  /// will be thrown.
  int threshold = 1000;

  /// Create an instance of [Fixtures].
  ///
  ///     Fixtures fixtures = new Fixtures();
  ///
  /// If you need a higher set of unique values from generators (like
  /// [name]) over the default [threshold] it can be optionally set:
  ///
  ///     Fixtures fixtures = new Fixtures(threshold: 5000);
  ///
  Fixtures({ this.threshold });

  /// Retrieve a namespaced [sequence].
  ///
  /// The [sequence] [int] returned for the namespace key will be increased
  /// incrementally for every call.
  ///
  ///     // emailSequence will equal `1` the first time it is called.
  ///     int emailSequence = fixtures.sequence('email');
  ///
  ///     // emailSequence will equal `2` the second time it is called, etc.
  ///     int nextEmailSequence = fixtures.sequence('email');
  ///
  int sequence(String key) {
    _sequences[key] ??= 0;
    return ++_sequences[key];
  }

  /// Generate a [Name].

  /// When called without the optional value a new, random [Name] will be
  /// automatically generated.
  ///
  /// When using the optional String value, a [Name] will be created with the
  /// value and then tracked. This allows subsequent calls for a random name
  /// to generate unique names even against ones that were explicitly set.
  /// Additional calls for explicit names will not be counted against the
  /// [threshold] after the first time.
  ///
  /// Throws [FixturesError] if the [threshold] for unique names is met.
  ///
  /// ## Examples
  ///
  /// Generates a Name object with the value 'Bob'.
  ///
  ///     Name bob = fixtures.name('Bob');
  ///
  /// Generates a [Name] object with a random value like "Brenda Wade". The
  /// random [Name] will never have the value "Bob".
  ///
  ///     Name name = fixtures.name('Bob');
  ///
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
  ///     User user = fixtures.user('Alice');
  ///
  User user({ String name }) {
    name ??= new Name().toString();

    int seq = sequence('email');
    String email = 'user-$seq@example.org';
    // TODO(jxson): automatically grab avatars from uifaces.com
    String id = uuid.v5(_uuidUser, email);
    String avatar = 'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg';
    return new User(id: id, name: name, email: email, locale: 'en', picture: avatar);
  }
}
