// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';

import '../user/alphatar.dart';
import 'label_list_item.dart';
import 'type_defs.dart';

const double _kProfileHeaderHeight = 73.0;

/// Renders a Google Gmail style inbox menu.
/// Contains a user banner followed by a list of [LabelGroup]s.
/// This widget provides the UI affordances to 'tab' between email folders.
class InboxMenu extends StatelessWidget {
  /// List of [LabelGroup]s to render
  List<LabelGroup> labelGroups;

  /// Callback if a folder is selected
  LabelActionCallback onSelectLabel;

  /// The selected folder. There can only be one currently selected folder
  Label selectedLabel;

  /// The [User] that is currently logged in
  User user;

  /// Creates new [InboxMenu]
  InboxMenu({
    Key key,
    @required this.labelGroups,
    @required this.user,
    this.onSelectLabel,
    this.selectedLabel,
  })
      : super(key: key) {
    assert(labelGroups != null);
    assert(user != null);
  }

  void _handleSelectFolder(Label folder) {
    if (onSelectLabel != null) {
      onSelectLabel(folder);
    }
  }

  Widget _buildLabelGroupBlock(LabelGroup folderGroup) {
    List<Widget> children = <Widget>[];

    // Add folder group title to children if needed.
    if (folderGroup.name != null && folderGroup.name.isNotEmpty) {
      children.add(new Container(
        padding: const EdgeInsets.only(
          top: 16.0,
          bottom: 8.0,
          left: 16.0,
          right: 16.0,
        ),
        child: new Text(
          folderGroup.name,
          style: new TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
          ),
        ),
      ));
    }

    folderGroup.labels.forEach((Label folder) {
      children.add(new LabelListItem(
        label: folder,
        selected: folder == selectedLabel,
        onSelect: _handleSelectFolder,
      ));
    });

    return new Container(
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(
            color: Colors.grey[300],
            width: 1.0,
          ),
        ),
      ),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// Builds User Profile 'banner' that is on top of the menu
  Widget _buildUserProfile() {
    return new Container(
      alignment: FractionalOffset.centerLeft,
      height: _kProfileHeaderHeight,
      child: new ListItem(
        title: new Text(user.name),
        subtitle: new Text(user.email),
        leading: new Alphatar.fromUser(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];

    children.add(_buildUserProfile());

    labelGroups.forEach((LabelGroup folderGroup) {
      children.add(_buildLabelGroupBlock(folderGroup));
    });

    return new Material(
      color: Colors.white,
      child: new Block(children: children),
    );
  }
}
