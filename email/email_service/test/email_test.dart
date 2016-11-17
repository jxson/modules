// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:email_service/api.dart' as api;
import 'package:googleapis/gmail/v1.dart';
import 'package:test/test.dart';

void main() {
  test('email.threads()', () async {
    api.Client client = api.client();
    GmailApi gmail = new GmailApi(client);

    print('making request');

    ListThreadsResponse response = await gmail.users.threads.list('me');

    response.threads.forEach((Thread thread) {
      print('title: ${thread.snippet}');
    });

    expect(true, equals(true));
  }, skip: 'TODO(jxson): make this a real test.');
}
