// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/email.dart';
import 'package:widgets_meta/widgets_meta.dart';

/// Callback type for updating the recipients of a new message
typedef void RecipientsChangedCallback(List<Mailbox> recipientList);

/// Google Inbox style 'recipient' field input.
class RecipientInput extends StatefulWidget {
  /// Callback function that is called everytime a new recipient is add or an
  /// existing recipient is removed. The updated recipient list is passed in
  /// as the callback parameter.
  final RecipientsChangedCallback onRecipientsChanged;

  /// List of recipients. This is a copy of what is fed in.
  final List<Mailbox> recipientList;

  /// Label for the recipient field. Ex. To, Cc Bcc...
  final String inputLabel;

  /// TextStyle used for the input and recipient chips
  ///
  /// Defaults to the subhead style of the theme
  final TextStyle inputStyle;

  /// TextStyle used for the label
  ///
  /// Defaults to the inputStyle with a grey-500 color
  final TextStyle labelStyle;

  /// Creates a [RecipientInput] instance
  RecipientInput({
    Key key,
    @required @ExampleValue('To:') this.inputLabel,
    this.onRecipientsChanged,
    this.inputStyle,
    this.labelStyle,
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
  final GlobalKey<EditableTextState> _inputFieldKey =
      new GlobalKey<EditableTextState>();

  /// If parent widget has a specified GlobalKey use that as the focusKey of
  /// the EditableText.
  /// Use a new GlobalKey otherwise.
  GlobalKey get focusKey {
    Key parentKey = config.key;
    if (parentKey is GlobalKey) {
      return parentKey;
    } else {
      return _inputFieldKey;
    }
  }

  @override
  void initState() {
    super.initState();
    _currentInput = const InputValue();
    _recipientList = new List<Mailbox>.from(config.recipientList);
  }

  void _notifyRecipientsChanged() {
    config.onRecipientsChanged
        ?.call(new List<Mailbox>.unmodifiable(_recipientList));
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
    TextStyle inputStyle = config.inputStyle ?? theme.textTheme.subhead;
    TextStyle labelStyle =
        config.labelStyle ?? inputStyle.copyWith(color: Colors.grey[500]);

    // Render Label
    List<Widget> rowChildren = <Widget>[
      new Container(
        margin: const EdgeInsets.only(right: 4.0),
        child: new Text(
          config.inputLabel,
          style: labelStyle,
        ),
      ),
    ];

    //render pre-existing recipients
    _recipientList.forEach((Mailbox recipient) {
      rowChildren.add(new Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: new Chip(
          label: new Text(
            recipient.displayText,
            style: config.inputStyle,
          ),
          onDeleted: () {
            _removeRecipient(recipient);
          },
        ),
      ));
    });

    //add text input
    rowChildren.add(new Container(
      width: 100.0,
      child: new InputField(
        onChanged: _handleInputChange,
        onSubmitted: _handleInputSubmit,
        value: _currentInput,
        focusKey: focusKey,
        key: _inputFieldKey,
        style: inputStyle,
      ),
    ));

    // TODO(dayang): Tapping on the entire container should bring focus to the
    // InputField.
    // https://fuchsia.atlassian.net/browse/SO-188
    //
    // This is blocked by Flutter Issue #7985
    // https://github.com/flutter/flutter/issues/7985
    return new Container(
      height: 56.0,
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(
            color: Colors.grey[200],
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: new Row(
        children: rowChildren,
      ),
    );
  }
}
