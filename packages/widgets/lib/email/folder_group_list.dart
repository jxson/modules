// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email/folder.dart';
import 'package:models/email/folder_group.dart';

import 'folder_list_item.dart';
import 'type_defs.dart';

/// Renders a list of [FolderGroup]s that is most commonly seen in the menu
/// sidebar of many email applications such as Gmail.
/// This widget provides the UI affordances to 'tab' between email folders.
class FolderGroupList extends StatelessWidget {
  /// List of [FolderGroup]s to render
  List<FolderGroup> folderGroups;

  /// Callback if a folder is selected
  FolderActionCallback onSelectFolder;

  /// The selected folder. There can only be one currently selected folder
  Folder selectedFolder;

  /// Creates new [FolderGroupList]
  FolderGroupList(
      {Key key,
      @required this.folderGroups,
      this.onSelectFolder,
      this.selectedFolder})
      : super(key: key) {
    assert(folderGroups != null);
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

  @override
  Widget build(BuildContext context) {
    // A lazy block is used since some FolderGroups might not have headers and
    // so the size is variable.
    // Ideally this is something that should be handled by a more universal
    // 'list with (sticky)headers' that is part of the Flutter framework.
    return new Material(
      color: Colors.white,
      child: new LazyBlock(
        delegate: new LazyBlockChildren(
          children: folderGroups.map(_buildFolderGroupBlock).toList(),
        ),
      ),
    );
  }
}
