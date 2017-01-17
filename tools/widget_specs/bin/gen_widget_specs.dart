// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:mustache/mustache.dart';
import 'package:path/path.dart' as path;
import 'package:strings/strings.dart' as strings;
import 'package:widget_specs/widget_specs.dart';

Future<Null> main(List<String> args) async {
  String error = checkArgs(args);
  if (error != null) {
    stderr.writeln(error);
    stdout.writeln('Usage: pub run gen_widget_specs.dart '
        '<widgets_package_dir> <output_dir>');
    exit(1);
  }

  String packageDir = args[0];
  String outputDir = args[1];

  List<WidgetSpecs> allWidgetSpecs = extractWidgetSpecs(packageDir)..sort();

  await writeIndex(outputDir, allWidgetSpecs);
  await Future.forEach(
    allWidgetSpecs,
    (WidgetSpecs specs) => writeWidgetSpecs(outputDir, specs),
  );
}

/// Check if the provided arguments are valid.
///
/// Returns the reason when there is an error; returns null otherwise.
String checkArgs(List<String> args) {
  if (args.length != 2) {
    return '';
  }

  String packageDir = args[0];
  if (!new Directory(packageDir).existsSync()) {
    return 'The specified package directory "$packageDir" does not exist.';
  }

  if (!new File(path.join(packageDir, 'pubspec.yaml')).existsSync()) {
    return 'The specified package directory "$packageDir" '
        'does not contain "pubspec.yaml" file.';
  }

  String outputDir = args[1];
  if (!new Directory(outputDir).existsSync()) {
    // Try creating the directory.
    try {
      new Directory(outputDir).createSync(recursive: true);
    } catch (e) {
      return 'Could not create the output directory "$outputDir".';
    }
  }

  return null;
}

const String _kHeader = '''
// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// THIS IS A GENERATED FILE. DO NOT MODIFY MANUALLY.''';

const String _kIndexFileTemplate = '''
{{ header }}

import 'package:flutter/widgets.dart';
import 'package:widget_specs/widget_specs.dart';

{{ imports }}

/// Map of widget specs.
final Map<String, WidgetSpecs> kWidgetSpecs = <String, WidgetSpecs>{
{{ items }}
};

/// Map of widget builders.
final Map<String, WidgetBuilder> kWidgetBuilders = <String, WidgetBuilder>{
{{ builders }}
};
''';

/// Writes the index file to the given output directory.
Future<Null> writeIndex(String outputDir, List<WidgetSpecs> widgetSpecs) async {
  String outputPath = path.join(outputDir, 'index.dart');

  Template template = new Template(
    _kIndexFileTemplate,
    htmlEscapeValues: false,
  );

  String imports = widgetSpecs.map((WidgetSpecs specs) {
    String underscoredName = strings.underscore(specs.name);
    return "import '$underscoredName.dart' as $underscoredName;";
  }).join('\n');

  String items = widgetSpecs.map((WidgetSpecs specs) {
    String underscoredName = strings.underscore(specs.name);
    return '  $underscoredName.kName: $underscoredName.kSpecs,';
  }).join('\n');

  String builders = widgetSpecs.map((WidgetSpecs specs) {
    String underscoredName = strings.underscore(specs.name);
    return '  $underscoredName.kName: $underscoredName.kBuilder,';
  }).join('\n');

  String output = template.renderString(<String, dynamic>{
    'header': _kHeader,
    'imports': imports,
    'items': items,
    'builders': builders,
  });

  await new File(outputPath).writeAsString(output);
}

const String _kSpecFileTemplate = '''
{{ header }}

import 'package:flutter/widgets.dart';
import 'package:widget_specs/widget_specs.dart';
import 'package:{{ package_name }}/{{ path }}';

/// Name of the widget.
const String kName = '{{ name }}';

/// [WidgetSpecs] of this widget.
final WidgetSpecs kSpecs = new WidgetSpecs(
  packageName: '{{ package_name }}',
  name: '{{ name }}',
  path: '{{ path }}',
  doc: \'\'\'
{{ doc }}\'\'\',
);

/// Builder for this widget.
final WidgetBuilder kBuilder = (BuildContext context) => new {{ name }}(
  {{ params }}
);
''';

/// Writes the widget specs to the given output directory.
Future<Null> writeWidgetSpecs(String outputDir, WidgetSpecs specs) async {
  String underscoredName = strings.underscore(specs.name);
  String outputPath = path.join(outputDir, '$underscoredName.dart');

  Template template = new Template(
    _kSpecFileTemplate,
    htmlEscapeValues: false,
  );

  // Escape single quotes within the doc comments.
  String escapedDoc = specs.doc?.replaceAllMapped(
    new RegExp(r"([^\\])'"),
    (Match m) => "${m.group(1)}\\\'",
  );

  String output = template.renderString(<String, dynamic>{
    'header': _kHeader,
    'package_name': specs.packageName,
    'name': specs.name,
    'path': specs.path,
    'doc': escapedDoc,
    'params': '', // TODO(youngseokyoon): provide parameter values.
  });

  await new File(outputPath).writeAsString(output);
}
