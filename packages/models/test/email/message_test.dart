// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:models/email.dart';
import 'package:test/test.dart';

void main() {
  test('.generateSnippet() should return text of message', () {
    String messageText = 'Puppies in Paris';
    Message message = new Message(text: messageText);
    expect(message.generateSnippet(), messageText);
  });

  test('.generateSnippet() should strip newline characters of message', () {
    String messageText = 'Puppies\nin Paris';
    Message message = new Message(text: messageText);
    expect(message.generateSnippet(), 'Puppies in Paris');
  });
}
