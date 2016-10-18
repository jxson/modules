// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/contact.dart';

import '../user/alphatar.dart';
import 'type_defs.dart';

const String _kDefaultBackgroundImage =
    'https://static.pexels.com/photos/2042/sea-city-mountains-landmark.jpg';

/// Height of header where background image is shown
const double _kHeaderHeight = 150.0;

/// Size (radius) of alphatar in Contact Detail
const double _kAlphatarRadius = 150.0;

/// Contact Details designed to take up much of the screen.
class ContactDetails extends StatelessWidget {
  /// User [Contact] that is being rendered
  Contact contact;

  /// Callback when given phone entry is selected for a call
  PhoneActionCallback onCall;

  /// Callback when given phone entry is selected for a text message
  PhoneActionCallback onText;

  /// Callback when given email entry is selected
  EmailActionCallback onEmail;

  /// Constructor
  ContactDetails(
      {Key key, @required this.contact, this.onCall, this.onText, this.onEmail})
      : super(key: key) {
    assert(contact != null);
  }

  void _handleCallPhone(PhoneEntry phoneEntry) {
    if (onCall != null) {
      onCall(phoneEntry);
    }
  }

  void _handleTextPhone(PhoneEntry phoneEntry) {
    if (onText != null) {
      onText(phoneEntry);
    }
  }

  void _handleSendEmail(EmailEntry emailEntry) {
    if (onEmail != null) {
      onEmail(emailEntry);
    }
  }

  /// Build background image
  Widget _buildBackgroundImage(ThemeData theme) {
    return new Container(
      height: _kHeaderHeight,
      decoration: new BoxDecoration(
        backgroundImage: new BackgroundImage(
          image: contact.backgroundImageUrl != null
              ? new NetworkImage(contact.backgroundImageUrl)
              : new NetworkImage(_kDefaultBackgroundImage),
          fit: ImageFit.cover,
          colorFilter: new ColorFilter.mode(
            theme.primaryColor.withAlpha(30),
            TransferMode.color,
          ),
        ),
      ),
    );
  }

  /// Build single quick action button
  Widget _buildQuickActionButton({
    IconData icon,
    VoidCallback onPressed,
    bool disabled,
    String label,
    ThemeData theme,
  }) {
    return new Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Material(
            type: MaterialType.circle,
            color: Colors.grey[200],
            child: new Container(
              padding: const EdgeInsets.all(4.0),
              child: new IconButton(
                size: 32.0,
                color: theme.buttonColor,
                icon: new Icon(icon),
                onPressed: disabled ? null : onPressed,
              ),
            ),
          ),
          new Container(
            padding: const EdgeInsets.only(top: 4.0),
            child: new Text(
              label,
              style: new TextStyle(
                color: Colors.grey[400],
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Action Buttons (Call, Message, Email)
  Widget _buildQuickActionButtonRow(ThemeData theme) {
    return new Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildQuickActionButton(
            icon: Icons.phone,
            onPressed: () => _handleCallPhone(contact.primaryPhoneNumber),
            disabled: contact.primaryPhoneNumber == null,
            label: 'Call',
            theme: theme,
          ),
          _buildQuickActionButton(
            icon: Icons.message,
            onPressed: () => _handleTextPhone(contact.primaryPhoneNumber),
            disabled: contact.primaryPhoneNumber == null,
            label: 'Message',
            theme: theme,
          ),
          _buildQuickActionButton(
            icon: Icons.email,
            onPressed: () => _handleSendEmail(contact.primaryEmail),
            disabled: contact.primaryEmail == null,
            label: 'Email',
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildNameHeader() {
    List<Widget> children = <Widget>[
      new Text(
        contact.user.name,
        style: new TextStyle(
          fontSize: 16.0,
        ),
      ),
    ];

    if (contact.regionPreview != null) {
      children.add(
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Icon(
              Icons.place,
              size: 14.0,
            ),
            new Text(
              contact.regionPreview,
            ),
          ],
        ),
      );
    }

    return new Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: new Center(
        child: new Column(
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return new CustomMultiChildLayout(
      delegate: new _ContactLayoutDelegate(),
      children: <Widget>[
        new LayoutId(
          id: _ContactLayoutDelegate.headerBackgroundId,
          child: _buildBackgroundImage(theme),
        ),
        new LayoutId(
          id: _ContactLayoutDelegate.contentId,
          child: new Container(
            padding: new EdgeInsets.only(
              top: _kAlphatarRadius / 2.0,
            ),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildNameHeader(),
                _buildQuickActionButtonRow(theme),
              ],
            ),
          ),
        ),
        new LayoutId(
          id: _ContactLayoutDelegate.alphatarId,
          child: new Container(
            padding: const EdgeInsets.all(1.0),
            decoration: new BoxDecoration(
              backgroundColor: theme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: new Alphatar.withUrl(
              avatarUrl: contact.user.picture,
              size: _kAlphatarRadius,
              letter: contact.user.name[0],
            ),
          ),
        ),
      ],
    );
  }
}

/// This is the LayoutDelegate that creates the 3 element custom layout:
/// - Header Area
/// - Content Area
/// - Avatar that overlaps and is in the middle of the Header and Content area
class _ContactLayoutDelegate extends MultiChildLayoutDelegate {
  static final String headerBackgroundId = 'headerBackground';
  static final String alphatarId = 'alphatar';
  static final String contentId = 'content';

  _ContactLayoutDelegate();

  @override
  void performLayout(Size size) {
    // Height is fixed for background.
    // Width should stretch out to the parent
    Size headerBackgroundSize = layoutChild(
      headerBackgroundId,
      new BoxConstraints.tightForFinite(
        height: _kHeaderHeight,
        width: size.width,
      ),
    );

    // Fixed size for Alphatar
    Size alphatarRadius = layoutChild(
      alphatarId,
      new BoxConstraints.tightFor(
        width: _kAlphatarRadius,
        height: _kAlphatarRadius,
      ),
    );

    // Content should stretch out to the rest of the parent
    layoutChild(
      contentId,
      new BoxConstraints.tightFor(
        height: size.height - _kHeaderHeight,
        width: size.width,
      ),
    );

    positionChild(headerBackgroundId, Offset.zero);
    positionChild(contentId, new Offset(0.0, headerBackgroundSize.height));
    positionChild(
      alphatarId,
      new Offset(
        headerBackgroundSize.width / 2.0 - alphatarRadius.width / 2.0,
        headerBackgroundSize.height - alphatarRadius.width / 2.0,
      ),
    );
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}
