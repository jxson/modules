// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:config_flutter/config.dart';
import 'package:googleapis/people/v1.dart' as contact;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:models/contact.dart';

/// The interface to the Google Contacts REST API.
class ContactAPI {
  /// Google OAuth scopes.
  List<String> scopes;
  Client _baseClient;
  AutoRefreshingAuthClient _client;
  contact.PeopleApi _contact;

  /// The [ContactAPI] constructor
  ContactAPI({
    @required String id,
    @required String secret,
    @required String token,
    @required DateTime expiry,
    @required String refreshToken,
    @required this.scopes,
  }) {
    assert(id != null);
    assert(secret != null);
    assert(token != null);
    assert(expiry != null);
    assert(refreshToken != null);

    ClientId clientId = new ClientId(id, secret);
    AccessToken accessToken = new AccessToken('Bearer', token, expiry);
    AccessCredentials credentials =
        new AccessCredentials(accessToken, refreshToken, scopes);
    _baseClient = new Client();
    _client = autoRefreshingClient(clientId, credentials, _baseClient);
    _contact = new contact.PeopleApi(_client);
  }

  /// Create an instance of [ContactAPI] by loading a config file.
  static Future<ContactAPI> fromConfig(String src) async {
    Config config = await Config.read(src);
    List<String> keys = <String>[
      'oauth_id',
      'oauth_secret',
      'oauth_token',
      'oauth_token_expiry',
      'oauth_refresh_token',
    ];
    config.validate(keys);

    return new ContactAPI(
        id: config.get('oauth_id'),
        secret: config.get('oauth_secret'),
        token: config.get('oauth_token'),
        expiry: DateTime.parse(config.get('oauth_token_expiry')),
        refreshToken: config.get('oauth_refresh_token'),
        scopes: config.scopes);
  }

  /// Gets a [Contact] from the Google People API
  /// Use the ID value of "me" to retrieve the current authenticated user
  Future<Contact> getUser(String id) async {
    assert(id != null);
    contact.Person person = await _contact.people.get('people/$id');
    return new Contact(
      id: person.resourceName,
      displayName: person.names.first?.displayName,
      givenName: person.names.first?.givenName,
      familyName: person.names.first?.familyName,
      addresses: person.addresses.map(_address).toList(),
      emails: person.emailAddresses.map(_email).toList(),
      phoneNumbers: person.phoneNumbers.map(_phoneNumber).toList(),
      photoUrl: person.photos.first?.url,
      backgroundImageUrl: person.coverPhotos.first?.url,
    );
  }

  /// Maps a Google People API address to the AddressEntry used in the Contacts
  /// module.
  AddressEntry _address(contact.Address address) {
    return new AddressEntry(
      city: address.city,
      street: address.streetAddress,
      region: address.region,
      postalCode: address.postalCode,
      country: address.country,
      countryCode: address.countryCode,
      label: address.formattedType,
    );
  }

  /// Maps a Google People API email address to the EmailEntry used in the
  /// Contacts module
  EmailEntry _email(contact.EmailAddress emailAddress) {
    return new EmailEntry(
      value: emailAddress.value,
      label: emailAddress.formattedType,
    );
  }

  /// Maps a Google People API phone number to the PhoneEntry used in the
  /// Contacts module
  PhoneEntry _phoneNumber(contact.PhoneNumber phoneNumber) {
    return new PhoneEntry(
      number: phoneNumber.value,
      label: phoneNumber.formattedType,
    );
  }
}
