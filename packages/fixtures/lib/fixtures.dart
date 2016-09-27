// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(jxson): Fixup dir structure so this works.
// import 'package:models/models.dart';
import 'package:models/user/user.dart';

class Fixtures {
  static User user({ String name }) {
    name ??= 'Jason';
    String email = 'jason@artifact.sh';

    return new User(name: name, email: email);
  }
}
