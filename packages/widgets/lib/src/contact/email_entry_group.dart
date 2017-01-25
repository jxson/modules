// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/contact.dart';

import 'contact_entry_group.dart';
import 'contact_entry_row.dart';
import 'type_defs.dart';

/// A widget representing a contact group of email entries
class EmailEntryGroup extends StatelessWidget {
  /// List of email entries to show
  final List<EmailEntry> emailEntries;

  /// Callback for when a email entry is selected
  final EmailActionCallback onSelectEmailEntry;

  /// Constructor
  EmailEntryGroup({
    Key key,
    @required this.emailEntries,
    this.onSelectEmailEntry,
  })
      : super(key: key) {
    assert(emailEntries != null);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = emailEntries
        .map((EmailEntry entry) => new ContactEntryRow(
            label: entry.label,
            child: new Text(
              entry.value,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: new TextStyle(
                fontSize: 16.0,
              ),
            ),
            onSelect: () {
              onSelectEmailEntry?.call(entry);
            }))
        .toList();
    return new ContactEntryGroup(
      child: new Column(children: children),
      icon: Icons.mail,
    );
  }
}
