// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:contact_api/contact_api.dart';
import 'package:flutter/material.dart';
import 'package:models/contact.dart';
import 'package:widgets/contact.dart';

import 'contact_card_screen.dart';

/// UI Widget that shows the authenticated User's list of contacts
class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => new _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  bool _loading = true;
  List<Contact> _contacts;
  Contact _selectedContact;
  ScrollController = _scrollCtrl = new ScrollController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<Null> _loadContacts() async {
    try {
      ContactAPI api = await ContactAPI.fromConfig('assets/config.json');
      List<Contact> contacts = await api.getConnections(
        sortOrder: ContactSortOrder.firstNameAscending,
      );
      setState(() {
        _contacts = contacts;
        _loading = false;
        print(_contacts);
      });
    } catch (exception, stackTrace) {
      print(exception);
      print(stackTrace);
    }
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

    return new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Expanded(
          child: new ListView(
            controller: _scrollCtrl,
            children: _contacts.map((Contact contact) {
              return new ContactListItem(
                  contact: contact,
                  onSelect: (Contact c) {
                    setState(() {
                      _selectedContact = c;
                    });
                  });
            }).toList(),
          ),
        ),
        new Expanded(
          child: _selectedContact != null
              ? new ContactCardScreen(contactId: _selectedContact.id)
              : new Container(),
        ),
      ],
    );
  }
}
