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

/// List item that represents a single Gmail style [Label]
class LabelListItem extends StatelessWidget {
  /// Given [Label] that this [LabelListItem] is associated with
  Label label;

  /// [IconData] for [Icon] that represents the given folder
  ///
  /// For Labels of type 'system' (from Gmail), the following priority
  /// determines the Icon:
  ///   1. Icon specified in constructor parameter
  ///   2. Icon based on LabelIdToIcon mapping
  ///   3. Default folder icon (Icons.folder)
  ///
  /// For folders that aren't of type system, the following priority determines
  /// the Icon:
  ///   1. Icon specified in constructor parameter
  ///   2. Default folder icon (Icons.folder)
  IconData icon;

  /// Callback if folder is selected
  LabelActionCallback onSelect;

  /// True if the folder is 'selected', this will highlight the item with a
  /// grey background.
  bool selected;

  /// Creates new LabelListItem
  LabelListItem({
    Key key,
    @required this.label,
    this.icon,
    this.onSelect,
    this.selected: false,
  })
      : super(key: key) {
    if (label.type == 'system') {
      icon ??= _folderIdToIcon[label.id] ?? Icons.folder;
    } else {
      icon ??= Icons.folder;
    }
    assert(label != null);
  }

  void _handleSelect() {
    if (onSelect != null) {
      onSelect(label);
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
        title: new Text(label.name),
        trailing: label.unread > 0
            ? new Text(
                '${label.unread}',
                style: new TextStyle(color: Colors.grey[600]),
              )
            : null,
      ),
    );
  }
}
