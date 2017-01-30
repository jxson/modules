// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/contact.dart';

import 'type_defs.dart';

/// A widget representing a contact group of phone entries (phone numbers)
class PhoneEntryGroup extends StatelessWidget {
  /// List of phone entries show
  final Contact contact;

  /// Callback for when a phone entry is selected
  final PhoneActionCallback onSelectPhoneEntry;

  /// Constructor
  PhoneEntryGroup({
    Key key,
    @required this.contact,
    this.onSelectPhoneEntry,
  })
      : super(key: key) {
    assert(contact != null);
  }

  Widget _buildPhoneEntryRow({
    PhoneEntry entry,
  }) {
    List<Widget> children = <Widget>[
      new Text(
        entry.number,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: new TextStyle(
          fontSize: 16.0,
        ),
      ),
    ];

    // Label
    if (entry.label != null) {
      children.add(new Text(
        entry.label,
        style: new TextStyle(
          color: Colors.grey[500],
          fontSize: 14.0,
        ),
      ));
    }

    return new InkWell(
      onTap: () {
        if (onSelectPhoneEntry != null) {
          onSelectPhoneEntry(entry);
        }
      },
      child: new Container(
        padding: const EdgeInsets.only(
          bottom: 16.0,
        ),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = contact.phoneNumbers
        .map((PhoneEntry entry) => _buildPhoneEntryRow(entry: entry))
        .toList();
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 4.0,
          ),
          child: new Icon(
            Icons.phone,
            color: Colors.grey[500],
          ),
        ),
        new Column(children: children),
      ],
    );
  }
}
