// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:fixtures/fixtures.dart';

void main() {
  Fixtures fixtures;

  setUp(() {
    fixtures = new Fixtures();
  });

  test('fixtures.add(...)', () {
    // Simple
    fixtures.add('foo', () {
      return 'bar';
    });

    String output = fixtures.get('foo');

    expect(output, equals('bar'));

    fixtures.add('user', () {
      User user = new User();
      return user;
    });

    User user = fixtures.get('user');

    expect(user is User, equals(true));
  });

  // test('sdfsd', () {
  //   User bob = User.generate(name: 'Bob');
  //
  //   expect(user.name, equals('fff'));
  //   expect(user.email, equals('jason@artifact.sh'));
  // });

  test('dfsdf', () {
    // User bob = new Fixture<User>(name: 'Bob');
    //
    // assert(bob.name == 'bob');
  });
}

abstract class Fixture<T> {

}

class Fixture<User> {
  // const Fixture<User>({ String name })
}

class User {
  String name;
  String email;

  User({ this.name, this.email }) {
    assert(name != null);
    assert(email != null);
  }
}

// class Factory<T> {
//   static T generate({ Map<String, dynamic> args });
//   static Future<T> generateAsync({ Map<String, dynamic> args });
// }
//
// class Factory<User> {
//   static Future<User> generate({ Map<String, dynamic> args }) async {
//     return new User();
//   }
// }
//
// class Factory<Foo> {
//   static Future<Foo> generate({ Map<String, dynamic> args }) async {
//     // some async work
//     Foo bar = await someLongWork();
//
//     return bar;
//   }
// }
//
// test('sdkjfs', () async {
//   User mockUser = await Factory<User>.generate(args: <String, dynamic>{'name': 'Bob'});
// });

// class UserFactory {
//   static User generate() {
//
//   }
//
//   // // http://stackoverflow.com/questions/12649573/how-do-you-build-a-singleton-in-dart/12649574#12649574
//   // static Fixtures fixtures = new Fixtures();
//   //
//   // /// svfds
//   // UserFactory({ String name, String email }) : super(name: name, email: email) {
//   //   // Generative values here.
//   //   // name ??= fixtures.get('name');
//   //   // email ??= fixtures.get('email');
//   //   name ??= 'jason';
//   //   email ??= 'jason@artifact.sh';
//   //   // this(name: name, email: email)
//   // }
// }

// https://www.dartlang.org/resources/dart-tips/dart-tips-ep-11

// It might be better to just have functions that return the correct type? Or
// implementations/mixins that override the constructors. Or something that
// can be implemented in the class directly?

// class User implements Fixture {...}

// User testUser = User.fixture(name: ...);
