// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/contact.dart';

import 'contact_entry_group.dart';
import 'contact_entry_row.dart';
import 'type_defs.dart';

/// A widget representing a contact group of address entries
class AddressEntryGroup extends StatelessWidget {
  /// List of phone entries to show
  final List<AddressEntry> addressEntries;

  /// Callback for when a address entry is selected
  final AddressActionCallback onSelectAddressEntry;

  /// Constructor
  AddressEntryGroup({
    Key key,
    @required this.addressEntries,
    this.onSelectAddressEntry,
  })
      : super(key: key) {
    assert(addressEntries != null);
  }

  Widget _buildAddressLine(String line) {
    return new Text(
      line,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: new TextStyle(
        fontSize: 16.0,
      ),
    );
  }

  Widget _buildAddress(AddressEntry entry) {
    List<Widget> addressLines = <Widget>[];

    if (entry.street != null) {
      addressLines.add(_buildAddressLine(entry.street));
    }

    if (entry.city != null ||
        entry.region != null ||
        entry.postalCode != null) {
      String line = '';
      if (entry.city != null) {
        line += '${entry.city}, ';
      }
      if (entry.region != null) {
        line += '${entry.region} ';
      }
      if (entry.postalCode != null) {
        line += '${entry.postalCode}';
      }
      addressLines.add(_buildAddressLine(line));
    }

    if (entry.country != null) {
      addressLines.add(_buildAddressLine(entry.country));
    }

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: addressLines,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = addressEntries
        .map((AddressEntry entry) => new ContactEntryRow(
            label: entry.label,
            child: _buildAddress(entry),
            onSelect: () {
              onSelectAddressEntry?.call(entry);
            }))
        .toList();
    return new ContactEntryGroup(
      child: new Column(children: children),
      icon: Icons.place,
    );
  }
}
