// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';

import 'type_defs.dart';

// TODO(dayang): Fill this out based on Gmail Label names & icons
Map<String, IconData> _folderIdToIcon = <String, IconData>{
  'STARRED': Icons.star,
  'INBOX': Icons.inbox,
  'TRASH': Icons.delete,
  'DRAFT': Icons.drafts,
};

/// List item that represents a single Gmail style [Folder]
class FolderListItem extends StatelessWidget {
  /// Given [Folder] that this [FolderListItem] is associated with
  Folder folder;

  /// [IconData] for [Icon] that represents the given folder
  ///
  /// For Folders of type 'system' (from Gmail), the following priority
  /// determines the Icon:
  ///   1. Icon specified in constructor parameter
  ///   2. Icon based on FolderIdToIcon mapping
  ///   3. Default folder icon (Icons.folder)
  ///
  /// For folders that aren't of type system, the following priority determines
  /// the Icon:
  ///   1. Icon specified in constructor parameter
  ///   2. Default folder icon (Icons.folder)
  IconData icon;

  /// Callback if folder is selected
  FolderActionCallback onSelect;

  /// True if the folder is 'selected', this will highlight the item with a
  /// grey background.
  bool selected;

  /// Creates new FolderListItem
  FolderListItem(
      {Key key,
      @required this.folder,
      this.icon,
      this.onSelect,
      this.selected: false})
      : super(key: key) {
    if (folder.type == 'system') {
      icon ??= _folderIdToIcon[folder.id] ?? Icons.folder;
    } else {
      icon ??= Icons.folder;
    }
    assert(folder != null);
  }

  void _handleSelect() {
    if (onSelect != null) {
      onSelect(folder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: selected ? Colors.grey[200] : Colors.white,
      child: new ListItem(
        enabled: true,
        onTap: _handleSelect,
        isThreeLine: false,
        leading: new Icon(
          icon,
          color: Colors.grey[600],
          size: 20.0,
        ),
        title: new Text(folder.name),
        trailing: folder.unread > 0
            ? new Text(
                '${folder.unread}',
                style: new TextStyle(color: Colors.grey[600]),
              )
            : null,
      ),
    );
  }
}
