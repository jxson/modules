// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'type_defs.dart';

/// Input for email message text
class MessageTextInput extends StatefulWidget {
  /// Initial text to prepopulate the input
  final String initialText;

  /// Callback function that is called everytime the subject text is changed
  final StringCallback onTextChange;

  /// TextStyle used for the input and recipient chips
  ///
  /// Defaults to the subhead style of the theme
  final TextStyle inputStyle;

  /// TextStyle used for the label
  ///
  /// Defaults to the inputStyle with a grey-500 color
  final TextStyle labelStyle;

  /// Constructor
  MessageTextInput({
    Key key,
    this.initialText,
    this.onTextChange,
    this.inputStyle,
    this.labelStyle,
  })
      : super(key: key);

  @override
  _MessageTextInputState createState() => new _MessageTextInputState();
}

class _MessageTextInputState extends State<MessageTextInput> {
  InputValue _currentInput;

  @override
  void initState() {
    super.initState();
    _currentInput = new InputValue(
      text: config.initialText ?? '',
    );
  }

  void _handleInputChange(InputValue input) {
    setState(() {
      _currentInput = input;
      config.onTextChange?.call(_currentInput.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle inputStyle = config.inputStyle ?? theme.textTheme.subhead;
    TextStyle labelStyle =
        config.labelStyle ?? inputStyle.copyWith(color: Colors.grey[500]);

    // TODO(dayang): Tapping on the entire container should bring focus to the
    // InputField.
    // https://fuchsia.atlassian.net/browse/SO-188
    //
    // This is blocked by Flutter Issue #7985
    // https://github.com/flutter/flutter/issues/7985
    return new Container(
      padding: const EdgeInsets.all(16.0),
      child: new InputField(
        onChanged: _handleInputChange,
        value: _currentInput,
        style: inputStyle,
        hintText: 'Compose email',
        hintStyle: labelStyle,
        // HACK(dayang): There is no way to specify unlimited lines as of now
        // https://fuchsia.atlassian.net/browse/SO-189
        //
        // This is blockded by Flutter isssue #8027
        // https://github.com/flutter/flutter/issues/8027
        maxLines: 9999,
      ),
    );
  }
}
