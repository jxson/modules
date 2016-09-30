// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(jxson): Fixup dir structure so this works.
// import 'package:models/models.dart';
// import 'name.dart';
import 'package:models/user/user.dart';
import 'package:uuid/uuid.dart';

import 'name.dart';

/// TODO document
class Fixtures {

  /// TODO document this.
  static Set<Name> names = new Set<Name>();

  Map<String, int> _sequences = new Map<String, int>();

  /// TODO document this.
  int threshold = 1000;

  /// TODO document this.
  Fixtures({ this.threshold }) {
    // TODO Add a gaurd on threshold to limit to the maximum number of possible names.
  }

  /// TODO document this.
  int sequence(String key) {
    _sequences[key] ??= 0;
    return ++_sequences[key];
  }

  /// TODO document this.
  // Add thershold for set length.
  Name name([String value]) {
    Name name;

    if (value != null) {
      name = new Name(value);
      names.add(name);
    } else {
      name = new Name();

      while (!names.add(name)) {
        name = new Name();
      }
    }

    return name;
  }


  static String _userRoot = uuid.v5(Uuid.NAMESPACE_URL, 'fuchsia.googlesource.com/fixtures/users');
  /// TODO document
  User user({ String name }) {
    name ??= new Name().toString();

    print('Generated name: $name');

    int seq = sequence('email');
    String email = 'user-$seq@example.org';
    // TODO(jxson): automatically grab avatars from uifaces.com
    String id = uuid.v5(_userRoot, email);
    String avatar = 'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg';
    return new User(id: id, name: name, email: email, locale: 'en', picture: avatar);
  }
}
