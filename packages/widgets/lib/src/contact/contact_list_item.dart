// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/contact.dart';

import '../user/alphatar.dart';
import 'type_defs.dart';

const double _kAvatarSize = 40.0;

class ContactListItem extends StatelessWidget {
  /// [Contact] for this list item
  final Contact contact;

  /// Callback if item is selected
  final ContactActionCallback onSelect;

  /// Constructor
  ContactListItem({
    Key key,
    @required this.contact,
    this.onSelect,
  })
      : super(key: key) {
    assert(contact != null);
  }

  void _handleSelect() {
    onSelect?.call(contact);
  }

  @override
  Widget build(BuildContext context) {
    final Widget avatar = new Container(
      child: new Alphatar.fromNameAndUrl(
        name: contact.displayName,
        avatarUrl: contact.photoUrl,
      ),
    );

    return new Material(
      color: Colors.white,
      child: new ListItem(
        enabled: true,
        onTap: _handleSelect,
        isThreeLine: false,
        leading: avatar,
        title: new Text(contact.displayName),
      ),
    );
  }
}
