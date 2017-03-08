// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:widgets_meta/widgets_meta.dart';

import '../email/mailbox.dart';
import '../fixtures/fixtures.dart';

/// Represents a Google User Account
/// Fields are based off the data from the Google Identity API:
/// https://developers.google.com/identity/
@Generator(ModelFixtures, 'user')
class User {
  /// Unique ID for user
  final String id;

  /// Email address for user
  final String email;

  /// Full name for user, Ex: John Doe
  final String name;

  /// 'First name' for user, Ex: John
  String givenName;

  /// 'Last name' for user, Ex: Doe
  String familyName;

  /// URL for user avatar
  final String picture;

  /// Location that user is associated with
  final String locale;

  Mailbox _mailbox;

  /// Constructor to create a new user
  User({
    this.id,
    @required this.email,
    @required this.name,
    this.givenName,
    this.familyName,
    this.picture,
    this.locale,
  }) {
    assert(name != null);
    assert(email != null);

    List<String> names = name.split(' ');
    givenName ??= names.first;
    familyName ??= names.last;
  }

  /// Construct a new User from JSON.
  factory User.fromJson(Map<String, dynamic> json) {
    return new User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      picture: json['picture'],
    );
  }

  /// Helper function for JSON.encode() creates JSON-encoded User object.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = new Map<String, dynamic>();

    json['id'] = id;
    json['email'] = email;
    json['name'] = name;
    json['picture'] = picture;

    return json;
  }

  /// Get an instance of Mailbox that maps to this user.
  Mailbox get mailbox {
    _mailbox ??= new Mailbox(
      displayName: name,
      address: email,
    );

    return _mailbox;
  }
}
