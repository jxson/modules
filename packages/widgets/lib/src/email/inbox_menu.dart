// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';

import '../user/alphatar.dart';
import 'folder_list_item.dart';
import 'type_defs.dart';

const double _kProfileHeaderHeight = 73.0;

/// Renders a Google Gmail style inbox menu.
/// Contains a user banner followed by a list of [FolderGroup]s.
/// This widget provides the UI affordances to 'tab' between email folders.
class InboxMenu extends StatelessWidget {
  /// List of [FolderGroup]s to render
  List<FolderGroup> folderGroups;

  /// Callback if a folder is selected
  FolderActionCallback onSelectFolder;

  /// The selected folder. There can only be one currently selected folder
  Folder selectedFolder;

  /// The [User] that is currently logged in
  User user;

  /// Creates new [InboxMenu]
  InboxMenu({
    Key key,
    @required this.folderGroups,
    @required this.user,
    this.onSelectFolder,
    this.selectedFolder,
  })
      : super(key: key) {
    assert(folderGroups != null);
    assert(user != null);
  }

  void _handleSelectFolder(Folder folder) {
    if (onSelectFolder != null) {
      onSelectFolder(folder);
    }
  }

  Widget _buildFolderGroupBlock(FolderGroup folderGroup) {
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

    folderGroup.folders.forEach((Folder folder) {
      children.add(new FolderListItem(
        folder: folder,
        selected: folder == selectedFolder,
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

    folderGroups.forEach((FolderGroup folderGroup) {
      children.add(_buildFolderGroupBlock(folderGroup));
    });

    return new Material(
      color: Colors.white,
      child: new Block(children: children),
    );
  }
}
