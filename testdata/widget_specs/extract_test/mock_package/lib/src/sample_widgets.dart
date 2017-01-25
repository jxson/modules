// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:widgets_meta/widgets_meta.dart';

/// This is a public [StatefulWidget].
class Widget01 extends StatefulWidget {
  /// An example [int] parameter for testing code generation.
  final int intParam;

  /// An example [bool] parameter for testing code generation.
  final bool boolParam;

  /// An example [String] parameter for testing code generation.
  final String stringParam;

  /// An example parameter without a provided example value.
  final dynamic noExampleValueParam;

  Widget01({
    Key key,
    @ExampleValue(42) this.intParam,
    @ExampleValue(true) this.boolParam,
    @ExampleValue('example string value!') this.stringParam,
    this.noExampleValueParam,
  })
      : super(key: key);
}

/// This is a private [StatefulWidget].
class _Widget02 extends StatefulWidget {}

/// This is a public [StatelessWidget].
class Widget03 extends StatelessWidget {}

/// This is a private [StatelessWidget].
class _Widget04 extends StatelessWidget {}

/// This is the [State] class for [Widget01].
class Widget01State extends State<Widget01> {}

class NoCommentWidget extends StatelessWidget {}
