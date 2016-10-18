// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

  /// Mime type of [Attachment]
  String mime;

  /// Constructor
  Attachment({
    /// This will need to be an async pipe to access data
    this.content,
    this.id,
    this.mime,
  });
}
