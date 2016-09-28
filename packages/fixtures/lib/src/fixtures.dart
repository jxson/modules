// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(jxson): Fixup dir structure so this works.
// import 'package:models/models.dart';
// import 'name.dart';
import 'package:models/user/user.dart';
import 'name.dart';

class Fixtures {
  Fixtures() {

  }

  Name name([String value]) {
    return new Name(value);
  }

  User user({ String name }) {
    // name ??= new Name().toString();
    name ??= 'Jason';
    String email = 'jason@artifact.sh';

    return new User(name: name, email: email);
  }
}
