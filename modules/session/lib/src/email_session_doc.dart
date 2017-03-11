// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:models/email.dart';
import 'package:models/fixtures.dart';
import 'package:models/user.dart';

// ignore: UNUSED_ELEMENT
void _log(String msg) {
  print('[email_session:SessionDoc] $msg');
}

/// Captures the state of an email session.
/// Can be serialized to Links to be shared with other modules.
class EmailSessionDoc {
  /// EmailSession doc id
  static const String docroot = 'emailSession';

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
    ModelFixtures fixtures = new ModelFixtures();
    user = fixtures.me();
    visibleLabels = fixtures.labels();
    visibleThreads = fixtures.threads();
    focusedThreadId = visibleThreads[0].id;
    fetchingLabels = false;
    fetchingThreads = false;
  }

  /// Construct from data in link document.
  bool readFromLink(String jsonString) {
    // ignore: STRONG_MODE_DOWN_CAST_COMPOSITE
    Map<String, dynamic> json = JSON.decode(jsonString);

    if (json == null) {
      return false;
    }

    return fromJson(json);
  }

  /// Write state to link
  void writeToLink(Link link) {
    link.updateObject(<String>[docroot], JSON.encode(this));
  }

  /// Convert a User object from Map<> representation to a concrete User object.
  bool fromJson(Map<String, dynamic> doc) {
    // The fact that we declared the parameter to be a Map does not mean
    // that Dart checks this at run time, so we need to make sure. If this
    // asserts, then you should check that the doc object is valid before
    // creating the EmailSessionDoc and calling fromJson().
    assert(doc is Map && doc[docroot] is Map);

    try {
      doc = doc[docroot];
      user = new User.fromJson(doc[userProp]);
      visibleLabels = _labelsFromJson(doc[visibleLabelsProp]);
      focusedLabelId = doc[focusedLabelIdProp];
      visibleThreads = _threadsFromJson(doc[visibleThreadsProp]);
      focusedThreadId = doc[focusedThreadIdProp];
      fetchingLabels = _readBool(doc, fetchingLabelsProp);
      fetchingThreads = _readBool(doc, fetchingThreadsProp);
      return true;
    } catch (e) {
      _log('Failed to cast Link properties $e');
      return false;
    }
  }

  /// Helper function for JSON.encode()
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      userProp: user?.toJson(),
      visibleLabelsProp: _labelsToJson(visibleLabels),
      focusedLabelIdProp: focusedLabelId,
      visibleThreadsProp: _threadsToJson(visibleThreads),
      focusedThreadIdProp: focusedThreadId,
      fetchingLabelsProp: fetchingLabels ?? false,
      fetchingThreadsProp: fetchingThreads ?? false,
    };
  }

  bool _readBool(Map<String, dynamic> doc, String prop) {
    if (doc[prop] is bool) return doc[prop];
    return false;
  }
}

List<Label> _labelsFromJson(List<Map<String, dynamic>> json) {
  List<Label> labels = <Label>[];

  if (json != null) {
    labels = json
        .map((Map<String, dynamic> value) => new Label.fromJson(value))
        .toList();
  }

  return labels;
}

/// Convert the collection into a JSON object.
List<Map<String, dynamic>> _labelsToJson(List<Label> labels) {
  List<Map<String, dynamic>> json = <Map<String, dynamic>>[];

  if (labels != null) {
    json = labels.map((Label label) => label.toJson()).toList();
  }

  return json;
}

List<Thread> _threadsFromJson(List<Map<String, dynamic>> json) {
  List<Thread> threads;

  if (json is List) {
    threads = json
        .map((Map<String, dynamic> value) => new Thread.fromJson(value))
        .toList();
  }

  return threads ?? <Thread>[];
}

/// Convert the collection into a JSON object.
List<Map<String, String>> _threadsToJson(List<Thread> labels) {
  List<Map<String, dynamic>> json = <Map<String, dynamic>>[];

  if (labels != null) {
    json = labels.map((Thread label) => label.toJson()).toList();
  }

  return json;
}
