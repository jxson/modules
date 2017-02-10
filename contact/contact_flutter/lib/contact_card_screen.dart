// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:contact_api/contact_api.dart';
import 'package:flutter/material.dart';
import 'package:models/contact.dart';
import 'package:widgets/contact.dart';

/// UI Widget that shows the authenticated User's Contact Card
class ContactCardScreen extends StatefulWidget {
  /// ID of contact to show
  final String contactId;

  /// Constructor
  ContactCardScreen({this.contactId});

  @override
  _ContactCardScreenState createState() => new _ContactCardScreenState();
}

class _ContactCardScreenState extends State<ContactCardScreen> {
  bool _loading = true;

  Contact _contact;

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  Future<Null> _loadContact() async {
    try {
      ContactAPI api = await ContactAPI.fromConfig('assets/config.json');
      Contact contact = await api.getUser(config.contactId ?? 'people/me');
      setState(() {
        _contact = contact;
        _loading = false;
      });
    } catch (exception, stackTrace) {
      print(exception);
      print(stackTrace);
    }
  }

  @override
  void didUpdateConfig(_) {
    _loadContact();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return new Center(
        child: new CircularProgressIndicator(
          value: null,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey[300]),
        ),
      );
    }

    return new ContactCard(
      contact: _contact,
    );
  }
}
