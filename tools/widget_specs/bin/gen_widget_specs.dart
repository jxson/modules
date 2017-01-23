// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:mustache/mustache.dart';
import 'package:path/path.dart' as path;
import 'package:strings/strings.dart' as strings;
import 'package:widget_specs/widget_specs.dart';

const double _kBoxRadius = 4.0;
const double _kMargin = 16.0;

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
import 'package:gallery/src/common/typedefs.dart';
import 'package:widget_specs/widget_specs.dart';

{{ imports }}

/// Map of widget specs.
final Map<String, WidgetSpecs> kWidgetSpecs = <String, WidgetSpecs>{
{{ items }}
};

/// Map of widget builders.
final Map<String, GalleryWidgetBuilder> kWidgetBuilders = <String, GalleryWidgetBuilder>{
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

import 'package:flutter/material.dart';
import 'package:gallery/src/common/typedefs.dart';
import 'package:widget_specs/widget_specs.dart';
import 'package:{{ package_name }}/{{ path }}';

{{# additional_imports }}
import '{{ additional_import }}';
{{/ additional_imports }}

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

/// Helper widget.
class _HelperWidget extends StatefulWidget {
  final double width;
  final double height;

  _HelperWidget(this.width, this.height);

  @override
  _HelperWidgetState createState() => new _HelperWidgetState();
}

/// Helper widget state.
class _HelperWidgetState extends State<_HelperWidget> {
  {{# params }}
  {{ param_type }} {{ param_name }};
  {{/ params }}

  @override
  Widget build(BuildContext context) {
    try {
      return new Block(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              border: new Border.all(color: Colors.grey[500]),
              borderRadius: new BorderRadius.all(new Radius.circular($_kBoxRadius)),
            ),
            margin: const EdgeInsets.all($_kMargin),
            child: new Container(),
          ),
          new Container(
            decoration: new BoxDecoration(
              border: new Border.all(color: Colors.grey[500]),
              borderRadius: new BorderRadius.all(new Radius.circular($_kBoxRadius)),
            ),
            margin: const EdgeInsets.all($_kMargin),
            child: new Container(
              margin: const EdgeInsets.all($_kMargin),
              child: new Row(
                children: <Widget>[
                  new Container(
                    width: config.width,
                    height: config.height,
                    child: new {{ name }}(
                      {{# params }}
                      {{ param_name }}: {{ param_name }},
                      {{/ params }}
                    ),
                  ),
                  new Expanded(child: new Container()),
                ],
              ),
            ),
          ),
        ]
      );
    } catch (e) {
      return new Text('Failed to build the example widget.\\n'
          'See the error message below:\\n\\n'
          '\$e');
    }
  }
}

/// Builder for this widget.
final GalleryWidgetBuilder kBuilder =
    (BuildContext context, double width, double height) =>
        new _HelperWidget(width, height);
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

  Set<String> additionalImports = new SplayTreeSet<String>();
  List<ParameterElement> params = <ParameterElement>[];

  ConstructorElement constructor = specs.classElement.constructors.firstWhere(
      (ConstructorElement c) => c.isDefaultConstructor,
      orElse: () => null);

  if (constructor != null) {
    params = new List<ParameterElement>.from(constructor.parameters);
    params.removeWhere((ParameterElement param) => param.type.name == 'Key');
    params.forEach((ParameterElement param) {
      String importUri = param.type.element.librarySource?.uri?.toString();
      if (importUri != null) {
        additionalImports.add(importUri);
      }
    });
  }

  additionalImports.remove('dart:core');

  String output = template.renderString(<String, dynamic>{
    'header': _kHeader,
    'package_name': specs.packageName,
    'name': specs.name,
    'path': specs.path,
    'doc': escapedDoc,
    'additional_imports': additionalImports
        .map((String uri) => <String, String>{
              'additional_import': uri,
            })
        .toList(),
    'params': params
        .map((ParameterElement param) => <String, String>{
              'param_type': param.type.name,
              'param_name': param.name,
            })
        .toList(),
  });

  await new File(outputPath).writeAsString(output);
}
