// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:quiver/core.dart' as quiver;

/// Represents a mailbox that can be a sender, recipient...
/// Mailbox is the name used in RFC 2822
class Mailbox {
  /// Email address
  String address;

  /// Human Friendly Display Name
  String displayName;

  /// Constructor
  Mailbox({
    @required this.address,
    this.displayName,
  }) {
    assert(address != null);
  }

  /// Text representation that will be typically used in UIs for this Mailbox
  /// Show the [displayName] if given, otherwise just fallback to the [address]
  String get displayText => displayName ?? address;

  @override
  String toString() {
    return '$displayName <$address>';
  }

  @override
  bool operator ==(Object o) =>
      o is Mailbox && o.address == address && o.displayName == displayName;

  @override
  int get hashCode => quiver.hashObjects(<dynamic>[
        address,
        displayName,
      ]);
}
