// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:apps.modular.services.document_store/document.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:models/email.dart';

List<Label> _mockLabels = <Label>[
  new Label(
    id: 'INBOX',
    name: 'Inbox',
    unread: 10,
    type: 'system',
  ),
  new Label(
    id: 'STARRED',
    name: 'Starred',
    unread: 10,
    type: 'system',
  ),
  new Label(
    id: 'DRAFT',
    name: 'Drafts',
    unread: 10,
    type: 'system',
  ),
  new Label(
    id: 'TRASH',
    name: 'Trash',
    unread: 10,
    type: 'system',
  ),
];

/// Captures the state of an email session.
/// Can be serialized to Links to be shared with other modules.
class EmailSessionDoc {
  /// EmailSession doc id
  static const String docid = 'emailSession';

  /// Visible Labels property name
  static const String visibleLabelsProp = 'visibleLabels';

  /// Focused label property name
  static const String focusedLabelIdProp = 'focusedLabelId';

  /// Fetching labels property name
  static const String fetchingLabelsProp = 'fetchingLabels';

  /// Fetching threads property name
  static const String fetchingThreadsProp = 'fetchingThreads';

  /// Available labels
  List<Label> labels;

  /// Currently focused label id
  String focusedLabelId;

  /// Indicates whether the labels are currently being fetched
  bool fetchingLabels;

  /// Indicates whether the threads are currently being fetched
  bool fetchingThreads;

  /// Default Constructor
  EmailSessionDoc();

  /// Fill with mock data
  EmailSessionDoc.withMockData() {
    labels = _mockLabels;
    focusedLabelId = 'INBOX';
    fetchingLabels = false;
    fetchingThreads = false;
  }

  /// Construct from data in link document.
  EmailSessionDoc.fromLinkDocument(Document doc) {
    labels =
        _fromJSON(JSON.decode(doc.properties[visibleLabelsProp]?.stringValue));
    focusedLabelId = doc.properties[focusedLabelIdProp]?.stringValue;
    fetchingLabels = _readBool(doc, fetchingLabelsProp);
    fetchingThreads = _readBool(doc, fetchingThreadsProp);
  }

  /// Write state to link
  void writeToLink(Link link) {
    link.setAllDocuments(<String, Document>{
      docid: new Document.init(docid, <String, Value>{
        visibleLabelsProp: new Value()
          ..stringValue = JSON.encode(_toJSON(labels)),
        focusedLabelIdProp: new Value()..stringValue = focusedLabelId,
        fetchingLabelsProp: new Value()..intValue = fetchingLabels ? 1 : 0,
        fetchingThreadsProp: new Value()..intValue = fetchingThreads ? 1 : 0,
      })
    });
  }

  bool _readBool(Document doc, String prop) {
    int val = doc.properties[prop]?.intValue;
    return val != null ? val > 0 : false;
  }
}

List<Label> _fromJSON(Map<String, List<Map<String, String>>> json) {
  List<Label> labels = <Label>[];

  if (json.containsKey('labels')) {
    json['labels'].forEach((Map<String, String> value) {
      labels.add(new Label.fromJSON(value));
    });
  }

  return labels;
}

/// Convert the collection into a JSON object.
Map<String, List<Map<String, String>>> _toJSON(List<Label> labels) {
  Map<String, List<Map<String, String>>> json =
      new Map<String, List<Map<String, String>>>();

  if (labels != null) {
    json['labels'] = labels.map((Label label) {
      return label.toJSON();
    }).toList();
  }

  return json;
}
