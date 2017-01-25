// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/contact.dart';

import 'address_entry_group.dart';
import 'email_entry_group.dart';
import 'phone_entry_group.dart';
import 'type_defs.dart';

/// Contact Details that usually contains information about a contact's phone,
/// email and address.
class ContactDetails extends StatelessWidget {
  /// User [Contact] that is being rendered
  final Contact contact;

  /// Callback when given address entry is selected
  final AddressActionCallback onSelectAddressEntry;

  /// Callback when given email entry is selected
  final EmailActionCallback onSelectEmailEntry;

  /// Callback when given phone entry is selected
  final PhoneActionCallback onSelectPhoneEntry;

  /// Constructor
  ContactDetails({
    Key key,
    @required this.contact,
    this.onSelectAddressEntry,
    this.onSelectEmailEntry,
    this.onSelectPhoneEntry,
  })
      : super(key: key) {
    assert(contact != null);
  }

  void _handleSelectEmailEntry(EmailEntry emailEntry) {
    onSelectEmailEntry?.call(emailEntry);
  }

  void _handleSelectPhoneEntry(PhoneEntry phoneEntry) {
    onSelectPhoneEntry?.call(phoneEntry);
  }

  void _handleSelectAddressEntry(AddressEntry addressEntry) {
    onSelectAddressEntry?.call(addressEntry);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> entryGroups = <Widget>[];

    if (contact.phoneNumbers.isNotEmpty) {
      entryGroups.add(new Container(
        padding: const EdgeInsets.all(16.0),
        child: new PhoneEntryGroup(
          phoneEntries: contact.phoneNumbers,
          onSelectPhoneEntry: _handleSelectPhoneEntry,
        ),
      ));
    }

    if (contact.emails.isNotEmpty) {
      entryGroups.add(new Container(
        padding: const EdgeInsets.all(16.0),
        child: new EmailEntryGroup(
          emailEntries: contact.emails,
          onSelectEmailEntry: _handleSelectEmailEntry,
        ),
      ));
    }

    if (contact.addresses.isNotEmpty) {
      entryGroups.add(new Container(
        padding: const EdgeInsets.all(16.0),
        child: new AddressEntryGroup(
          addressEntries: contact.addresses,
          onSelectAddressEntry: _handleSelectAddressEntry,
        ),
      ));
    }

    return new Material(
      color: Colors.white,
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: entryGroups,
      ),
    );
  }
}
