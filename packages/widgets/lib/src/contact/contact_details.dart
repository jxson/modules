// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/contact.dart';

import 'phone_entry_group.dart';
import 'type_defs.dart';

/// Contact Details that usually contains information about a contact's phone,
/// email and address.
class ContactDetails extends StatelessWidget {
  /// User [Contact] that is being rendered
  final Contact contact;

  /// Callback when given phone entry is selected
  final PhoneActionCallback onSelectPhoneEntry;

  /// Constructor
  ContactDetails({
    Key key,
    @required this.contact,
    this.onSelectPhoneEntry,
  })
      : super(key: key) {
    assert(contact != null);
  }

  void _handleSelectPhoneEntry(PhoneEntry phoneEntry) {
    onSelectPhoneEntry?.call(phoneEntry);
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.white,
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.all(16.0),
            child: new PhoneEntryGroup(
              contact: contact,
              onSelectPhoneEntry: _handleSelectPhoneEntry,
            ),
          ),
        ],
      ),
    );
  }
}
