// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Various Contact Entry Types

/// A Contacts Email Entry
class EmailEntry {
  /// Email address, e.g. littlePuppyCoco@cute.org
  String value;

  /// Optional label to give for the email, e.g. Work, Personal...
  String label;

  /// Constructor
  EmailEntry({
    this.value,
    this.label,
  });

  @override
  String toString() {
    return '$value';
  }
}

/// An Contacts Address Entry
class AddressEntry {
  /// City, ex Mountain View
  String city;

  /// Full street name, e.g. 1842 Shoreline
  String street;

  /// Province or State, e.g. California, Chihuahua
  String region;

  /// Post/zip code, e.g. 95129
  String postalCode;

  /// Country, e.g. United States of America, China
  String country;

  /// Country code for given country, e.g. CN
  // TODO(dayang): Create list of country codes
  // https://fuchsia.atlassian.net/browse/SO-45
  String countryCode;

  /// Optional label to give for the address, e.g. Home, Work...
  String label;

  /// Constructor
  AddressEntry({
    this.city,
    this.street,
    this.region,
    this.postalCode,
    this.country,
    this.countryCode,
    this.label,
  });

  @override
  String toString() {
    return '$street, $city, $region, $postalCode, $country, '
        '$countryCode';
  }
}

/// A Contacts Phone Number Entry
class PhoneEntry {
  /// Phone number, e.g. 911, 1-408-111-2222
  String number;

  /// Optional label to give for the phone entry, e.g. Cell, Home, Work...
  String label;

  /// Constructor
  PhoneEntry({
    this.number,
    this.label,
  });
}

/// Various common social network types
enum SocialNetworkType {
  /// Facebook
  /// www.facebook.com
  facebook,

  /// LinkedIn
  /// www.linkedin.com
  linkedin,

  /// Twitter
  /// www.twitter.com
  twitter,

  /// Other social networks
  other,
}

/// Social network account associated with given Contact
class SocialNetworkEntry {
  /// Type of social network, e.g. Facebook, Twitter ...
  SocialNetworkType type;

  /// User account of Social Network, ex @google
  // TODO(dayang): Validation/formatting/adaptation of common social media
  // accounts.
  // https://fuchsia.atlassian.net/browse/SO-45
  String account;

  /// Constructor
  SocialNetworkEntry({
    this.type,
    this.account,
  });

  @override
  String toString() {
    return '$account';
  }
}
