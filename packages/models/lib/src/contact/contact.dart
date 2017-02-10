// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'entry_types.dart';

/// A Model representing a contact entry
class Contact {
  /// Unique Identifier for given contact
  final String id;

  /// Full name of contact, usually givenName + familyName
  final String displayName;

  /// First name for contact
  final String givenName;

  /// Last name for contact
  final String familyName;

  /// Physical addresses associated with contact
  final List<AddressEntry> addresses;

  /// Email addresses associated with contact
  final List<EmailEntry> emails;

  /// Phone numbers associated with contact
  final List<PhoneEntry> phoneNumbers;

  /// Social Networks associated with contact
  final List<SocialNetworkEntry> socialNetworks;

  /// URL for background image
  final String backgroundImageUrl;

  /// URL for main contact profile photo;
  final String photoUrl;

  /// Constructor
  Contact({
    this.id,
    this.displayName,
    this.givenName,
    this.familyName,
    this.backgroundImageUrl,
    this.photoUrl,
    List<AddressEntry> addresses,
    List<EmailEntry> emails,
    List<PhoneEntry> phoneNumbers,
    List<SocialNetworkEntry> socialNetworks,
  })
      : addresses =
            new List<AddressEntry>.unmodifiable(addresses ?? <AddressEntry>[]),
        emails = new List<EmailEntry>.unmodifiable(emails ?? <EmailEntry>[]),
        phoneNumbers =
            new List<PhoneEntry>.unmodifiable(phoneNumbers ?? <PhoneEntry>[]),
        socialNetworks = new List<SocialNetworkEntry>.unmodifiable(
            socialNetworks ?? <SocialNetworkEntry>[]);

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
