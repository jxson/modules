// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:quiver/core.dart' as quiver;

/// Represents a mailbox that can be a sender, recipient...
/// Mailbox is the name used in RFC 2822
class Mailbox {
  /// Email address
  final String address;

  /// Human Friendly Display Name
  final String displayName;

  /// Constructor
  Mailbox({
    @required this.address,
    this.displayName,
  }) {
    assert(address != null);
  }

  /// Creates a [Mailbox] from a string. (e.g., "John Doe <john.doe@abc.xyz>")
  //
  // TODO(dayang): Handle all cases of RFC email 'mailbox' formats
  // https://fuchsia.atlassian.net/browse/SO-49
  factory Mailbox.fromString(String rawString) {
    // Group 0: Entire raw string
    // Group 1: Display name in case there is an explicit email address given in
    //          <> brackets. Otherwise, Group 1 is the email address.
    // Group 2: Email address part including the brackets.
    // Group 3: Email address part without the brackets.
    RegExp exp = new RegExp(r'^\s*"*([^"<>]*)"*\s*(<(.*@.*)>)?\s*$');
    Match match = exp.firstMatch(rawString);

    String address, displayName;
    if (match == null) {
      address = rawString.trim();
    } else if (match.group(3) != null) {
      displayName = match.group(1).isNotEmpty ? match.group(1).trim() : null;
      address = match.group(3).trim();
    } else if (match.group(1) != null) {
      address = match.group(1).trim();
    } else {
      throw new FormatException('Not a valid mailbox format: "$rawString"');
    }

    return new Mailbox(address: address, displayName: displayName);
  }

  /// Create an instance from JSON.
  factory Mailbox.fromJson(Map<String, dynamic> json) {
    return new Mailbox(
      displayName: json['name'],
      address: json['email'],
    );
  }

  /// JSON representation.
  Map<String, String> toJson() {
    return <String, String>{
      'name': displayName,
      'email': address,
    };
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
