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
    bool showPrimaryStar: false,
    ThemeData theme,
  }) {
    List<Widget> children = <Widget>[];

    // Add label if it exists for given entry
    // If not, just add an empty container for spacing
    children.add(new Container(
      width: 60.0,
      margin: const EdgeInsets.only(right: 8.0),
      child: new Text(
        entry.label ?? '',
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: new TextStyle(
          color: Colors.grey[500],
          fontSize: 16.0,
        ),
      ),
    ));

    // Add actual phone number
    children.add(new Flexible(
      flex: 1,
      child: new Text(
        entry.number,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: new TextStyle(
          fontSize: 16.0,
        ),
      ),
    ));

    children.add(new Container(
      width: 50.0,
      height: 24.0,
      child: showPrimaryStar
          ? new Icon(
              Icons.star,
              color: theme.primaryColor,
            )
          : null,
    ));

    return new InkWell(
      onTap: () {
        if (onSelectPhoneEntry != null) {
          onSelectPhoneEntry(entry);
        }
      },
      child: new Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: new Row(
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    List<Widget> children = contact.phoneNumbers
        .map((PhoneEntry entry) => _buildPhoneEntryRow(
              entry: entry,
              showPrimaryStar: entry == contact.primaryPhoneNumber &&
                  contact.phoneNumbers.length > 1,
              theme: theme,
            ))
        .toList();
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 4.0,
          ),
          child: new Icon(
            Icons.phone,
            color: theme.primaryColor,
          ),
        ),
        new Container(
          constraints: new BoxConstraints(maxWidth: 300.0),
          child: new Column(children: children),
        ),
      ],
    );
  }
}
