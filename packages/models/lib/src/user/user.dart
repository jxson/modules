// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

/// Represents a Google User Account
/// Fields are based off the data from the Google Identity API:
/// https://developers.google.com/identity/
class User {
  /// Unique ID for user
  String id;

  /// Email address for user
  String email;

  /// Full name for user, Ex: John Doe
  String name;

  /// 'First name' for user, Ex: John
  String givenName;

  /// 'Last name' for user, Ex: Doe
  String familyName;

  /// URL for user avatar
  String picture;

  /// Location that user is associated with
  String locale;

  /// Constructor to create a new user
  User(
      {this.id,
      @required this.email,
      @required this.name,
      this.givenName,
      this.familyName,
      this.picture,
      this.locale}) {
    assert(name != null);
    assert(email != null);

    List<String> names = name.split(' ');
    givenName ??= names.first;
    familyName ??= names.last;
  }

  /// Construct a new User from JSON.
  factory User.fromJson(Map<String, String> json) {
    return new User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      picture: json['picture'],
    );
  }

  /// User as JSON.
  Map<String, String> toJson() {
    Map<String, String> json = new Map<String, String>();

    json['id'] = id;
    json['email'] = email;
    json['name'] = name;
    json['picture'] = picture;

    return json;
  }
}
