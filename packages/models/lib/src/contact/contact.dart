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

  /// URL for background image
  String backgroundImageUrl;

  /// Constructor
  Contact(
      {@required this.user,
      this.addresses: const <AddressEntry>[],
      this.emails: const <EmailEntry>[],
      this.phoneNumbers: const <PhoneEntry>[],
      this.socialNetworks: const <SocialNetworkEntry>[],
      this.backgroundImageUrl}) {
    assert(this.user != null);
    this.addresses ??= <AddressEntry>[];
    this.emails ??= <EmailEntry>[];
    this.phoneNumbers ??= <PhoneEntry>[];
    this.socialNetworks ??= <SocialNetworkEntry>[];
  }

  /// The primary address is the first address in the list of addresses
  /// Returns null if there is no address for contact
  AddressEntry get primaryAddress {
    if (addresses.isEmpty) {
      return null;
    } else {
      return addresses[0];
    }
  }

  /// The primary email is the first entry in the list of emails
  /// Returns null if there is no email for contact
  EmailEntry get primaryEmail {
    if (emails.isEmpty) {
      return null;
    } else {
      return emails[0];
    }
  }

  /// The primary phone number is the first entry in the list of phone numbers
  /// Returns null if there is no phone number for contact
  PhoneEntry get primaryPhoneNumber {
    if (phoneNumbers.isEmpty) {
      return null;
    } else {
      return phoneNumbers[0];
    }
  }

  /// Gets the region preview (city, region) for a given contact
  /// Uses the primary address to generate the preview
  /// Returns null if there is no primary address of if there is no city or
  /// region for the primary address.
  String get regionPreview {
    if (primaryAddress == null ||
        (primaryAddress.city == null && primaryAddress.region == null)) {
      return null;
    }
    if (primaryAddress.city != null && primaryAddress.region != null) {
      return '${primaryAddress.city}, ${primaryAddress.region}';
    } else {
      return primaryAddress.city ?? primaryAddress.region;
    }
  }
}
