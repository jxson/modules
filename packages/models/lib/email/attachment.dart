// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Enum Types for Attachment
/// These current attachments are more for UI prototyping purposes and might
/// not reflect the final types.
// TODO(dayang): Update to reflect real MIME types found in email
// https://fuchsia.atlassian.net/browse/SO-25
enum AttachmentType {
  /// Image
  image,

  /// A document, ex. Google Docs
  doc,

  /// A youtube video URL
  youtube,
}

/// Data model that represents a email attachment.
/// The current implementation is based on UI requirements and not reflective
/// of actual email MIME types.
// TODO(dayang): Update to reflect real MIME types found in email
// https://fuchsia.atlassian.net/browse/SO-25
class Attachment {
  /// String data that represents the attachment
  String content;

  /// Id for [Attachment]
  /// This is field is present in any Gmail attachment:
  /// https://developers.google.com/gmail/api/v1/reference/users/messages/attachments#resource
  String id;

  /// Type of [Attachment]
  AttachmentType type;

  /// Constructor
  Attachment({
    this.content,
    this.id,
    this.type,
  });
}
