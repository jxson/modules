// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:clients/gmail_client.dart';
import 'package:flutter/http.dart' as http;
import 'package:mockito/mockito_no_mirrors.dart';
import 'package:models/email/mailbox.dart';
import 'package:models/email/message.dart';
import 'package:models/email/thread.dart';
import 'package:test/test.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockHttpResponse extends Mock implements http.Response {}

const String _listThreadsResponse = '''
{
  "threads": [
    {
      "id": "thread-01",
      "snippet": "Snippet for thread-01",
      "historyId": "1234"
    },
    {
      "id": "thread-02",
      "snippet": "Snippet for thread-02",
      "historyId": "1234"
    }
  ]
}
''';

DateTime _timestamp = new DateTime.now();

Map<String, String> _getThreadResponses = new Map<String, String>.fromIterable(
  <String>['thread-01', 'thread-02'],
  key: (String threadId) => threadId,
  value: (String threadId) => '''
{
  "id": "$threadId",
  "snippet": "Snippet for $threadId",
  "historyId": "1234",
  "messages": [
    {
      "id": "$threadId-message-01",
      "threadId": "$threadId",
      "labelIds": [],
      "snippet": "Snippet for $threadId-message-01",
      "historyId": "1234",
      "internalDate": "${_timestamp.millisecondsSinceEpoch}",
      "payload": {
        "mimeType": "text/plain",
        "filename": "",
        "headers": [
          {
            "name": "To",
            "value": "fx-recipient <fx-test-recipient@example.com>"
          },
          {
            "name": "From",
            "value": "fx-sender <fx-test-sender@example.com>"
          },
          {
            "name": "Cc",
            "value": "fx-cc <fx-test-cc@example.com>"
          },
          {
            "name": "Subject",
            "value": "Subject for $threadId-message-01"
          }
        ]
      }
    },
    {
      "id": "$threadId-message-02",
      "threadId": "$threadId",
      "labelIds": [],
      "snippet": "Snippet for $threadId-message-02",
      "historyId": "1234",
      "internalDate": "${_timestamp.millisecondsSinceEpoch}",
      "payload": {
        "mimeType": "text/plain",
        "filename": "",
        "headers": [
          {
            "name": "To",
            "value": "fx-recipient <fx-test-recipient@example.com>"
          },
          {
            "name": "From",
            "value": "fx-sender <fx-test-sender@example.com>"
          },
          {
            "name": "Cc",
            "value": "fx-cc <fx-test-cc@example.com>"
          },
          {
            "name": "Subject",
            "value": "Subject for $threadId-message-02"
          }
        ]
      }
    }
  ]
}
''',
);

void main() {
  setUpAll(() {
    _timestamp = _timestamp.subtract(new Duration(
      microseconds: _timestamp.microsecond,
    ));
  });

  test('getThreads() should return a well-formed GetThreadsResponse', () async {
    // Mock the http client.
    _MockHttpClient mockClient = new _MockHttpClient();

    // The first call to get the list of threads.
    Uri uriThreads = new Uri(
      scheme: 'https',
      host: 'www.googleapis.com',
      path: '/gmail/v1/users/me/threads',
    );
    _MockHttpResponse responseThreads = new _MockHttpResponse();
    when(responseThreads.body).thenReturn(_listThreadsResponse);

    when(mockClient.get(uriThreads, headers: typed(any, named: 'headers')))
        .thenReturn(new Future<http.Response>.value(responseThreads));

    // Subsequent call for getting the threads.
    for (String threadId in <String>['thread-01', 'thread-02']) {
      Uri uriThread = new Uri(
        scheme: 'https',
        host: 'www.googleapis.com',
        path: '/gmail/v1/users/me/threads/$threadId',
        queryParameters: <String, dynamic>{
          'labelIds': 'INBOX',
        },
      );
      _MockHttpResponse responseThread = new _MockHttpResponse();
      when(responseThread.body).thenReturn(_getThreadResponses[threadId]);

      when(mockClient.get(uriThread, headers: typed(any, named: 'headers')))
          .thenReturn(new Future<http.Response>.value(responseThread));
    }

    // Initialize the GmailClient and call getThreads.
    GmailClient gmail = new GmailClient(
      httpClientProvider: () => mockClient,
    );

    GmailGetThreadsResponse response = await gmail.getThreads();

    // Verify the response.
    List<Thread> expected = <Thread>[
      new Thread(
        id: 'thread-01',
        snippet: 'Snippet for thread-01',
        historyId: '1234',
        messages: <Message>[
          new Message(
            id: 'thread-01-message-01',
            sender: new Mailbox(
              address: 'fx-test-sender@example.com',
              displayName: 'fx-sender',
            ),
            senderProfileUrl: null,
            recipientList: <Mailbox>[
              new Mailbox(
                address: 'fx-test-recipient@example.com',
                displayName: 'fx-recipient',
              )
            ],
            ccList: <Mailbox>[
              new Mailbox(
                address: 'fx-test-cc@example.com',
                displayName: 'fx-cc',
              )
            ],
            subject: 'Subject for thread-01-message-01',
            text: 'Snippet for thread-01-message-01',
            timestamp: _timestamp,
            isRead: true,
          ),
          new Message(
            id: 'thread-01-message-02',
            sender: new Mailbox(
              address: 'fx-test-sender@example.com',
              displayName: 'fx-sender',
            ),
            senderProfileUrl: null,
            recipientList: <Mailbox>[
              new Mailbox(
                address: 'fx-test-recipient@example.com',
                displayName: 'fx-recipient',
              )
            ],
            ccList: <Mailbox>[
              new Mailbox(
                address: 'fx-test-cc@example.com',
                displayName: 'fx-cc',
              )
            ],
            subject: 'Subject for thread-01-message-02',
            text: 'Snippet for thread-01-message-02',
            timestamp: _timestamp,
            isRead: true,
          ),
        ],
      ),
      new Thread(
        id: 'thread-02',
        snippet: 'Snippet for thread-02',
        historyId: '1234',
        messages: <Message>[
          new Message(
            id: 'thread-02-message-01',
            sender: new Mailbox(
              address: 'fx-test-sender@example.com',
              displayName: 'fx-sender',
            ),
            senderProfileUrl: null,
            recipientList: <Mailbox>[
              new Mailbox(
                address: 'fx-test-recipient@example.com',
                displayName: 'fx-recipient',
              )
            ],
            ccList: <Mailbox>[
              new Mailbox(
                address: 'fx-test-cc@example.com',
                displayName: 'fx-cc',
              )
            ],
            subject: 'Subject for thread-02-message-01',
            text: 'Snippet for thread-02-message-01',
            timestamp: _timestamp,
            isRead: true,
          ),
          new Message(
            id: 'thread-02-message-02',
            sender: new Mailbox(
              address: 'fx-test-sender@example.com',
              displayName: 'fx-sender',
            ),
            senderProfileUrl: null,
            recipientList: <Mailbox>[
              new Mailbox(
                address: 'fx-test-recipient@example.com',
                displayName: 'fx-recipient',
              )
            ],
            ccList: <Mailbox>[
              new Mailbox(
                address: 'fx-test-cc@example.com',
                displayName: 'fx-cc',
              )
            ],
            subject: 'Subject for thread-02-message-02',
            text: 'Snippet for thread-02-message-02',
            timestamp: _timestamp,
            isRead: true,
          ),
        ],
      ),
    ];

    expect(response.threads, equals(expected));
  });
}
