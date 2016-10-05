// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import '../user/user.dart';
import 'entry_types.dart';

/// A Model representing a contact entry
class Contact {
  /// User data associated with the [Contact] entry
  /// For now, we will use the User Model which is based on Google's User
  /// Account schema.
  ///
  /// This will contain data for things such as Name and Avatar.
  User user;

  /// Physical addresses associated with contact
  List<AddressEntry> addresses;

  /// Email addresses associated with contact
  List<EmailEntry> emails;

  /// Phone numbers associated with contact
  List<PhoneEntry> phoneNumbers;

  /// Social Networks associated with contact
  List<SocialNetworkEntry> socialNetworks;

  /// Constructor
  Contact(
      {@required this.user,
      this.addresses,
      this.emails,
      this.phoneNumbers,
      this.socialNetworks}) {
    assert(this.user != null);
  }
}
