// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:clients/email_client.dart';
import 'package:clients/gmail_client.dart';
import 'package:flutter/material.dart';
import 'package:models/email/mock_thread.dart';
import 'package:models/email/thread.dart';
import 'package:widgets/email/thread_list_item.dart';
import 'package:widgets/email/thread_list_item_single_line.dart';
import 'package:widgets/email/type_defs.dart';

/// This screen displays an inbox.
class EmailInboxScreen extends StatefulWidget {
  /// Creates a [EmailInboxScreen] instance.
  EmailInboxScreen({Key key, this.accessToken}) : super(key: key);

  /// Access token for the email API.
  final String accessToken;

  @override
  _EmailInboxScreenState createState() => new _EmailInboxScreenState();
}

class _EmailInboxScreenState extends State<EmailInboxScreen> {
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  bool _inProgress = false;
  String _errorMessage;

  final List<Thread> _threads = <Thread>[];
  bool _singleLine = false;
  EmailClient _emailClient;

  @override
  void initState() {
    super.initState();

    if (config.accessToken != null) {
      _emailClient = new GmailClient(accessToken: config.accessToken);

      // Get the email threads using the email client.
      _emailClient.getThreads().then((GetThreadsResponse response) {
        if (mounted) {
          setState(() {
            _inProgress = false;
            _threads.addAll(response.threads);
          });
        }
      }).catchError((Exception e) {
        if (mounted) {
          setState(() {
            _inProgress = false;
            _errorMessage =
                'Error occurred while retrieving email threads:\n$e';
          });
        }
      });

      _inProgress = true;
    } else {
      _threads.add(new MockThread());
      _threads.add(new MockThread());
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _key,
      appBar: new AppBar(
        title: new Text('Email - Inbox'),
        actions: <Widget>[
          new PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                    new PopupMenuItem<String>(
                      value: 'SingleLine',
                      child: new Text('Toggle Single Line'),
                    ),
                  ],
              onSelected: (String value) {
                switch (value) {
                  case 'SingleLine':
                    setState(() {
                      _singleLine = !_singleLine;
                    });
                    break;
                }
              }),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Just show a progress bar while waiting for the email data.
    if (_inProgress) {
      return new Center(child: new CircularProgressIndicator());
    }

    // Show the error message, if an error occurred while retrieving email data.
    if (_errorMessage != null) {
      return new Text(_errorMessage);
    }

    List<Widget> listItems = <Widget>[];
    _threads.forEach((Thread t) {
      listItems.add(_createThreadListItem(context, t));
    });

    return new Block(children: listItems);
  }

  Widget _createThreadListItem(BuildContext context, Thread thread) {
    Key key = new ObjectKey(thread);

    ThreadActionCallback handleSelect = (Thread thread) {
      Navigator.pushNamed(
        context,
        '/email/thread/${config.accessToken}/${thread.id}',
      );
    };

    return _singleLine
        ? new ThreadListItemSingleLine(
            key: key,
            thread: thread,
            onSelect: handleSelect,
          )
        : new ThreadListItem(
            key: key,
            thread: thread,
            onSelect: handleSelect,
          );
  }
}
