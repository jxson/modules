// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Some basic attachment types
enum AttachmentType {
  /// Youtube Video
  youtubeVideo,

  /// USPS Shipping code
  uspsShipping,

  /// A order recipet for an online purchase
  orderReceipt,
}

/// Simple representation of an email attachment
class Attachment {
  /// Type of the attachment
  AttachmentType type;

  /// String representation of the value/data of the attachment
  String value;

  /// ID for given attachment
  String id;

  /// Constructor
  Attachment({
    this.type,
    this.value,
    this.id,
  });

  /// Construct a new [Attachment] from JSON.
  factory Attachment.fromJson(Map<String, dynamic> json) {
    int type = int.parse(json['type']);

    return new Attachment(
      id: json['id'],
      value: json['value'],
      type: AttachmentType.values[type],
    );
  }

  /// JSON representation.
  Map<String, String> toJson() {
    return <String, String>{
      'id': id,
      'type': type.index.toString(),
      'value': value,
    };
  }
}
