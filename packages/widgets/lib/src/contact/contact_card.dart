// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/contact.dart';

import 'contact_details.dart';
import 'contact_header.dart';

/// The Contact Card is a full screen view that contains the contact details,
/// shared activity and other activity tabs.
class ContactCard extends StatelessWidget {
  /// User [Contact] that is being rendered
  final Contact contact;

  /// Constructor
  ContactCard({
    Key key,
    @required this.contact,
  })
      : super(key: key) {
    assert(contact != null);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return new DefaultTabController(
      length: 3,
      child: new Block(children: <Widget>[
        new ContactHeader(contact: contact),
        new Container(
          decoration: new BoxDecoration(
            border: new Border(
              top: new BorderSide(color: Colors.grey[300]),
              bottom: new BorderSide(color: Colors.grey[300]),
            ),
          ),
          // TODO(dayang): The TabBar should be "sticky" when the user scrolls
          // above the TabBar point
          //
          // We will wait for the Flutter scroll refactor to complete before
          // any implementation
          // https://github.com/flutter/flutter/projects/3
          //
          // Jira Issue SO-182: https://fuchsia.atlassian.net/browse/SO-182
          child: new TabBar(
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey[700],
            tabs: <Widget>[
              new Tab(text: 'DETAILS'),
              new Tab(text: 'YOU AND APARNA'),
              new Tab(text: 'OTHER ACTIVITY')
            ],
          ),
        ),
        // HACK(dayang): Currently a TabBarView must be nested inside a
        // widget with bounded constraints. However, the height of
        // of the TabBarView is dynamic because of different content
        // for each contact.
        //
        // We sidestep this for now by giving a fixed height for each
        // TabBarView child.
        //
        // The Flutter team is currently addressing this issue through
        // a refactor of scrolling logic:
        // https://github.com/flutter/flutter/projects/3
        //
        // Jira Issue SO-180: https://fuchsia.atlassian.net/browse/SO-180
        new Container(
          height: 800.0,
          decoration: new BoxDecoration(
            backgroundColor: Colors.grey[300],
          ),
          child: new TabBarView(children: <Widget>[
            new Container(
              height: 800.0,
              child: new ContactDetails(
                contact: contact,
              ),
            ),
            new Container(
              height: 800.0,
              child: new Text('You and Aparna Content'),
            ),
            new Container(
              height: 800.0,
              child: new Text('Other Activty Content'),
            ),
          ]),
        ),
      ]),
    );
  }
}
