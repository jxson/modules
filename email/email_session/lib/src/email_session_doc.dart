// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:apps.modular.services.document_store/document.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';

void _log(String msg) {
  print('[email_session:SessionDoc] $msg');
}

List<Label> _mockLabels = <Label>[
  new Label(
    id: 'INBOX',
    name: 'Inbox',
    unread: 5,
    type: 'system',
  ),
  new Label(
    id: 'STARRED',
    name: 'Starred',
    unread: 0,
    type: 'system',
  ),
  new Label(
    id: 'DRAFT',
    name: 'Drafts',
    unread: 18,
    type: 'system',
  ),
  new Label(
    id: 'TRASH',
    name: 'Trash',
    unread: 1,
    type: 'system',
  ),
];

/// Temp convenience method for generating mock threads
List<Thread> mockThreads(int size) => new List<Thread>.generate(
    size, (int index) => new MockThread(id: index.toString()));

/// Captures the state of an email session.
/// Can be serialized to Links to be shared with other modules.
class EmailSessionDoc {
  /// EmailSession doc id
  static const String docid = 'emailSession';

  /// User property name
  static const String userProp = 'user';

  /// Visible labels property name
  static const String visibleLabelsProp = 'visibleLabels';

  /// Focused label property name
  static const String focusedLabelIdProp = 'focusedLabelId';

  /// Visible labels property name
  static const String visibleThreadsProp = 'visibleThreads';

  /// Focused thread property name
  static const String focusedThreadIdProp = 'focusedThreadId';

  /// Fetching labels property name
  static const String fetchingLabelsProp = 'fetchingLabels';

  /// Fetching threads property name
  static const String fetchingThreadsProp = 'fetchingThreads';

  /// The current user
  User user;

  /// Available labels
  List<Label> visibleLabels;

  /// Currently focused label id
  String focusedLabelId;

  /// The currently visible threads.
  List<Thread> visibleThreads;

  /// Currently focused thread id
  String focusedThreadId;

  /// Indicates whether the labels are currently being fetched
  bool fetchingLabels;

  /// Indicates whether the threads are currently being fetched
  bool fetchingThreads;

  /// Default Constructor
  EmailSessionDoc();

  /// Fill with mock data
  EmailSessionDoc.withMockData() {
    user = new User(
      name: 'Coco Yang',
      email: 'coco@cu.te',
      familyName: 'Yang',
      givenName: 'Coco',
      picture:
          'https://raw.githubusercontent.com/dvdwasibi/DogsOfFuchsia/master/coco.jpg',
    );
    visibleLabels = _mockLabels;
    visibleThreads = mockThreads(_mockLabels[0].unread);
    focusedThreadId = visibleThreads[0].id;
    focusedLabelId = _mockLabels[0].id;
    fetchingLabels = false;
    fetchingThreads = false;
  }

  /// Construct from data in link document.
  void readFromLink(Map<String, Document> docs) {
    Document doc = docs[docid];
    if (doc != null) {
      user =
          new User.fromJson(JSON.decode(doc.properties[userProp]?.stringValue));
      visibleLabels = _labelsFromJson(
          JSON.decode(doc.properties[visibleLabelsProp]?.stringValue));
      focusedLabelId = doc.properties[focusedLabelIdProp]?.stringValue;
      visibleThreads = _threadsFromJson(
          JSON.decode(doc.properties[visibleThreadsProp]?.stringValue));
      focusedThreadId = doc.properties[focusedThreadIdProp]?.stringValue;
      fetchingLabels = _readBool(doc, fetchingLabelsProp);
      fetchingThreads = _readBool(doc, fetchingThreadsProp);
    }
  }

  /// Write state to link
  void writeToLink(Link link) {
    // NOTE(youngseokyoon): In the current framework design, Value object
    // themselves are nullable, but their internal values aren't.
    // (see: //apps/modular/services/document_store/document.fidl)
    //
    // In other words, if we do this below:
    //
    //     focusedLabelId: new Value()..stringValue = null,
    //
    // it will silently fail at FIDL layer and break things.
    link.setAllDocuments(<String, Document>{
      docid: new Document.init(docid, <String, Value>{
        userProp: user != null
            ? (new Value()..stringValue = JSON.encode(user.toJson()))
            : null,
        visibleLabelsProp: visibleLabels != null
            ? (new Value()
              ..stringValue = JSON.encode(_labelsToJson(visibleLabels)))
            : null,
        focusedLabelIdProp: focusedLabelId != null
            ? (new Value()..stringValue = focusedLabelId)
            : null,
        visibleThreadsProp: visibleThreads != null
            ? (new Value()
              ..stringValue = JSON.encode(_threadsToJson(visibleThreads)))
            : null,
        focusedThreadIdProp: focusedThreadId != null
            ? (new Value()..stringValue = focusedThreadId)
            : null,
        fetchingLabelsProp: new Value()
          ..intValue = (fetchingLabels ?? false) ? 1 : 0,
        fetchingThreadsProp: new Value()
          ..intValue = (fetchingThreads ?? false) ? 1 : 0,
      })
    });
  }

  bool _readBool(Document doc, String prop) {
    int val = doc.properties[prop]?.intValue;
    return val != null ? val > 0 : false;
  }
}

List<Label> _labelsFromJson(Map<String, List<Map<String, String>>> json) {
  List<Label> labels = <Label>[];

  if (json.containsKey('labels')) {
    json['labels'].forEach((Map<String, String> value) {
      labels.add(new Label.fromJson(value));
    });
  }

  return labels;
}

/// Convert the collection into a JSON object.
Map<String, List<Map<String, String>>> _labelsToJson(List<Label> labels) {
  Map<String, List<Map<String, String>>> json =
      new Map<String, List<Map<String, String>>>();

  if (labels != null) {
    json['labels'] = labels.map((Label label) {
      return label.toJson();
    }).toList();
  }

  return json;
}

List<Thread> _threadsFromJson(Map<String, List<Map<String, String>>> json) {
  List<Thread> threads = <Thread>[];

  if (json.containsKey('threads')) {
    json['threads'].forEach((Map<String, String> value) {
      threads.add(new Thread.fromJson(value));
    });
  }

  return threads;
}

/// Convert the collection into a JSON object.
Map<String, List<Map<String, String>>> _threadsToJson(List<Thread> labels) {
  Map<String, List<Map<String, String>>> json =
      new Map<String, List<Map<String, String>>>();

  if (labels != null) {
    json['threads'] = labels.map((Thread label) {
      return label.toJson();
    }).toList();
  }

  return json;
}
