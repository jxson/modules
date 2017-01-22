// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';

/// Callback type for updating the recipients of a new message
typedef void RecipientsChangedCallback(List<Mailbox> recipientList);

/// Google Inbox style 'recipient' field input.
class RecipientInput extends StatefulWidget {
  /// Callback function that is called everytime a new recipient is add or an
  /// existing recipient is removed. The updated recipient list is passed in
  /// as the callback parameter.
  RecipientsChangedCallback onRecipientsChanged;

  /// List of recipients. This is a copy of what is fed in.
  final List<Mailbox> recipientList;

  /// Label for the recipient field. Ex. To, Cc Bcc...
  final String inputLabel;

  /// Creates a [RecipientInput] instance
  RecipientInput({
    Key key,
    @required this.inputLabel,
    this.onRecipientsChanged,
    List<Mailbox> recipientList,
  })
      : recipientList = recipientList ?? const <Mailbox>[],
        super(key: key) {
    assert(inputLabel != null);
  }

  @override
  _RecipientInputState createState() => new _RecipientInputState();
}

class _RecipientInputState extends State<RecipientInput> {
  /// 'Working copy' of the recipient list.
  /// This is what is passed through in the onRecipientsChanged callback
  List<Mailbox> _recipientList;

  /// The 'in progress' text of the new recipient being composed in the input
  InputValue _currentInput;

  /// GlobalKey that is required for an EditableText
  GlobalKey<EditableTextState> _editableTextKey =
      new GlobalKey<EditableTextState>();

  /// If parent widget has a specified GlobalKey use that as the focusKey of
  /// the EditableText.
  /// Use a new GlobalKey otherwise.
  GlobalKey get focusKey {
    Key parentKey = config.key;
    if (parentKey is GlobalKey) {
      return parentKey;
    } else {
      return _editableTextKey;
    }
  }

  @override
  void initState() {
    super.initState();
    _currentInput = const InputValue();
    _recipientList = new List<Mailbox>.from(config.recipientList);
  }

  void _notifyRecipientsChanged() {
    config.onRecipientsChanged(new List<Mailbox>.unmodifiable(_recipientList));
  }

  void _handleInputChange(InputValue input) {
    // TODO(dayang): If current newRecipient text is a valid email address
    // that is an existing contact, automatically add it to the recipientList.
    // https://fuchsia.atlassian.net/browse/SO-107
    setState(() {
      _currentInput = input;
    });
  }

  void _handleInputSubmit(InputValue input) {
    // TODO(dayang): Email validation + cleanup (white spaces)
    // https://fuchsia.atlassian.net/browse/SO-108
    if (input.text.isNotEmpty) {
      setState(() {
        _recipientList.add(new Mailbox(
          address: input.text,
        ));
        _currentInput = const InputValue();
        _notifyRecipientsChanged();
      });
    }
  }

  void _removeRecipient(Mailbox recipient) {
    setState(() {
      _recipientList.remove(recipient);
      _notifyRecipientsChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // Render Label
    List<Widget> rowChildren = <Widget>[
      new Text(
        config.inputLabel,
        style: new TextStyle(
          color: Colors.grey[500],
        ),
      ),
    ];

    //render pre-existing recipients
    _recipientList.forEach((Mailbox recipient) {
      rowChildren.add(new Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: new Chip(
          label: new Text(recipient.displayText),
          onDeleted: () {
            _removeRecipient(recipient);
          },
        ),
      ));
    });

    //add text input
    rowChildren.add(new Container(
      width: 100.0,
      child: new EditableText(
        onChanged: _handleInputChange,
        onSubmitted: _handleInputSubmit,
        value: _currentInput,
        platform: theme.platform,
        style: theme.textTheme.body1,
        focusKey: focusKey,
        key: _editableTextKey,
        cursorColor: theme.textSelectionColor,
        selectionColor: theme.textSelectionColor,
      ),
    ));

    return new Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 8.0,
      ),
      child: new Row(
        children: rowChildren,
      ),
    );
  }
}
