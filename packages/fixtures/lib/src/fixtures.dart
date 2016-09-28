// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(jxson): Fixup dir structure so this works.
// import 'package:models/models.dart';
// import 'name.dart';
import 'package:models/user/user.dart';
import 'name.dart';

class Fixtures {
  // The created Set is a plain LinkedHashSet. As such, it considers elements that a
  // re equal (using ==) to be indistinguishable, and requires them to have a com
  // patible Object.hashCode implementation.
  static Set<Name> names = new Set<Name>();

  int threshold;

  Fixtures({ this.threshold }) {
    threshold ??= 1000;

    // Add a gaurd on threshold to limit to the maximum number of possible names.
  }

  // Add thershold for set length.
  Name name([String value]) {
    Name name;

    if (value != null) {
      name = new Name(value);
      names.add(name);
    } else {
      name = new Name();

      while (!names.add(name)) {
        // print('==> "${name.toString()}" already exists. Trying again...');
        name = new Name();
      }
    }

    return name;
  }

  User user({ String name }) {
    // name ??= new Name().toString();
    name ??= 'Jason';
    String email = 'jason@artifact.sh';

    return new User(name: name, email: email);
  }
}
