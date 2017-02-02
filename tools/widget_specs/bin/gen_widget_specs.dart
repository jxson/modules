// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dart_style/dart_style.dart';
import 'package:mustache/mustache.dart';
import 'package:path/path.dart' as path;
import 'package:strings/strings.dart' as strings;
import 'package:widget_specs/src/utils.dart';
import 'package:widget_specs/widget_specs.dart';

const double _kBoxRadius = 4.0;
const double _kMargin = 16.0;

final DartFormatter _formatter = new DartFormatter();

Future<Null> main(List<String> args) async {
  String error = checkArgs(args);
  if (error != null) {
    stderr.writeln(error);
    stdout.writeln('Usage: pub run gen_widget_specs.dart '
        '<widgets_package_dir> <output_dir> [<fuchsia_root>]');
    exit(1);
  }

  String packageDir = args[0];
  String outputDir = args[1];
  String fuchsiaRoot = args.length == 3 ? args[2] : null;

  List<WidgetSpecs> allWidgetSpecs =
      extractWidgetSpecs(packageDir, fuchsiaRoot: fuchsiaRoot)..sort();

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
  if (args.length < 2 || args.length > 3) {
    return 'Invalid number of arguments.';
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

  if (args.length == 2) {
    return null;
  }

  String fuchsiaRoot = args[2];
  if (!new Directory(fuchsiaRoot).existsSync()) {
    return 'The specified fuchsia root "$fuchsiaRoot" does not exist.';
  }

  // The fuchsia root dir should be an ancestor of the given package dir.
  if (!path.isWithin(fuchsiaRoot, packageDir)) {
    return 'The fuchsia root should be an ancestor of the package dir.';
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

import 'package:gallery/src/widget_specs/typedefs.dart';
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

  await new File(outputPath).writeAsString(_formatter.format(output));
}

const String _kSpecFileTemplate = '''
{{ header }}

import 'package:config_flutter/config.dart';
import 'package:flutter/material.dart';
import 'package:gallery/src/widget_specs/typedefs.dart';
import 'package:gallery/src/widget_specs/utils.dart';
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
  {{# path_from_fuchsia_root }}
  pathFromFuchsiaRoot: '{{ path_from_fuchsia_root }}',
  {{/ path_from_fuchsia_root }}
  doc: \'\'\'
{{ doc }}\'\'\',
  exampleWidth: {{ example_width }},
  exampleHeight: {{ example_height }},
);

/// Helper widget.
class _HelperWidget extends StatefulWidget {
  final Config config;
  final double width;
  final double height;

  _HelperWidget(this.config, this.width, this.height);

  @override
  _HelperWidgetState createState() => new _HelperWidgetState();
}

/// Helper widget state.
class _HelperWidgetState extends State<_HelperWidget> {
  {{# params }}
  {{ param_type }} {{ param_name }};
  {{/ params }}
  {{# generators }}
  {{ generator_declaration }};
  {{/ generators }}

  Key uniqueKey = new UniqueKey();

  @override
  void initState() {
    super.initState();

    {{# params }}
    {{ param_name }} = {{ param_initial_value }};
    {{/ params }}
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    try {
      widget = new {{ name }}(
        key: uniqueKey,
        {{# params }}
        {{ param_name }}: {{ param_name }},
        {{/ params }}
      );
    } catch (e) {
      widget = new Text('Failed to build the widget.\\n'
          'See the error message below:\\n\\n'
          '\$e');
    }

    return new Block(
      children: <Widget>[
        new Container(
          decoration: new BoxDecoration(
            border: new Border.all(color: Colors.grey[500]),
            borderRadius: new BorderRadius.all(new Radius.circular($_kBoxRadius)),
          ),
          margin: const EdgeInsets.all($_kMargin),
          child: new Container(
            child: new Container(
              margin: const EdgeInsets.all($_kMargin),
              child: new Block(
                children: <Widget>[
                  new Text(
                    'Parameters',
                    style: new TextStyle(fontWeight: FontWeight.bold),
                  ),
                  new Table(
                    children: <TableRow>[
                      {{# params }}
                      buildTableRow(
                        context,
                        <Widget>[
                          new Text('{{ param_type }}'),
                          new Text('{{ param_name }}'),
                          {{ param_controller }},
                        ],
                      ),
                      {{/ params }}
                    ],
                    columnWidths: <int, TableColumnWidth>{
                      0: const IntrinsicColumnWidth(),
                      1: const FixedColumnWidth($_kMargin),
                      2: const IntrinsicColumnWidth(),
                      3: const FixedColumnWidth($_kMargin),
                      4: const FlexColumnWidth(1.0),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  ),
                ],
              ),
            ),
          ),
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
                  child: widget,
                ),
                new Expanded(child: new Container()),
              ],
            ),
          ),
        ),
      ]
    );
  }

  void updateKey() {
    uniqueKey = new UniqueKey();
  }
}

/// Builder for this widget.
final GalleryWidgetBuilder kBuilder =
    (BuildContext context, Config config, double width, double height) =>
        new _HelperWidget(config, width, height);
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
  String escapedDoc = _escapeQuotes(specs.doc);

  Set<String> additionalImports = new SplayTreeSet<String>();
  Set<DartType> generators = new SplayTreeSet<DartType>(
    (DartType t1, DartType t2) => t1.name.compareTo(t2.name),
  );
  List<ParameterElement> params = <ParameterElement>[];

  ConstructorElement constructor = specs.classElement.constructors.firstWhere(
      (ConstructorElement c) => c.isDefaultConstructor,
      orElse: () => null);

  if (constructor != null) {
    params = new List<ParameterElement>.from(constructor.parameters);
    params.removeWhere((ParameterElement param) => param.type.name == 'Key');
    params.forEach((ParameterElement param) =>
        _addImportForElement(additionalImports, param.type.element));
  }

  // The parameter controllers / initial values should be generated here first
  // so that the additional imports can be safely added.
  List<Map<String, String>> paramList = params
      .map((ParameterElement param) => <String, String>{
            'param_type': param.type.name,
            'param_name': param.name,
            'param_controller': _generateParamControllerCode(
              additionalImports,
              generators,
              specs,
              param,
            ),
            'param_initial_value': _generateInitialValueCode(
              additionalImports,
              generators,
              specs,
              param,
            ),
          })
      .toList();

  List<Map<String, String>> generatorList = generators
      .map((DartType generatorType) => <String, String>{
            'generator_declaration': '${generatorType.name} '
                '${lowerCamelize(generatorType.name)} = '
                'new ${generatorType.name}()',
          })
      .toList();

  String output = template.renderString(<String, dynamic>{
    'header': _kHeader,
    'package_name': specs.packageName,
    'name': specs.name,
    'path': specs.path,
    'path_from_fuchsia_root': specs.pathFromFuchsiaRoot != null
        ? <String, String>{'path_from_fuchsia_root': specs.pathFromFuchsiaRoot}
        : null,
    'doc': escapedDoc,
    'example_width': specs.exampleWidth ?? 'null',
    'example_height': specs.exampleHeight ?? 'null',
    'additional_imports': additionalImports
        .map((String uri) => <String, String>{
              'additional_import': uri,
            })
        .toList(),
    'params': paramList,
    'generators': generatorList,
  });

  await new File(outputPath).writeAsString(_formatter.format(output));
}

String _generateParamControllerCode(
  Set<String> additionalImports,
  Set<DartType> generators,
  WidgetSpecs specs,
  ParameterElement param,
) {
  // TODO(youngseokyoon): handle more types of values.

  // For int type, use a TextField where the user can type in the integer value.
  if (param.type.name == 'int') {
    return '''new TextField(
      initialValue: new InputValue(text: (${param.name} ?? 0).toString()),
      isDense: true,
      keyboardType: TextInputType.number,
      onChanged: (InputValue value) {
        try {
          int intValue = int.parse(value.text);
          setState(() {
            ${param.name} = intValue;
            updateKey();
          });
        } catch (e) {
          // Do nothing.
        }
      },
    )''';
  }

  // For bool type, use a Switch widget.
  // Since we don't want the Switch widget to take up the entire width, add an
  // empty widget next to it.
  if (param.type.name == 'bool') {
    return '''new Row(
      children: <Widget>[
        new Switch(
          value: ${param.name} ?? false,
          onChanged: (bool value) {
            setState(() {
              ${param.name} = value;
              updateKey();
            });
          },
        ),
        new Expanded(child: new Container()),
      ],
    )''';
  }

  // For double type, use a TextField where the user can type the value.
  if (param.type.name == 'double') {
    return '''new TextField(
        initialValue: new InputValue(text: (${param.name} ?? 0.0).toString()),
        isDense: true,
        keyboardType: TextInputType.number,
        onChanged: (InputValue value) {
          try {
            double doubleValue = double.parse(value.text);
            setState(() {
              ${param.name} = doubleValue;
              updateKey();
            });
          } catch (e) {
            // Do nothing.
          }
        },
      )''';
  }

  // For String type, use a TextField where the user can type in the value.
  if (param.type.name == 'String') {
    // If this parameter should be retrieved from the config.json file, do not
    // show the values on the screen.
    String configKey = specs.getConfigKey(param);
    if (configKey != null) {
      return """new ConfigKeyText(
        configKey: '${_escapeQuotes(configKey)}',
        configValue: ${param.name},
      )""";
    }

    return '''new TextField(
      initialValue: new InputValue(text: ${param.name} ?? ''),
      isDense: true,
      onChanged: (InputValue value) {
        setState(() {
          ${param.name} = value.text;
          updateKey();
        });
      },
    )''';
  }

  // Handle enum parameters with a popup menu button.
  if (_isEnumParameter(param)) {
    return '''new PopupMenuButton<${param.type.name}>(
      itemBuilder: (BuildContext context) {
        return ${param.type.name}.values.map((${param.type.name} value) {
          return new PopupMenuItem<${param.type.name}>(
            value: value,
            child: new Text(value.toString()),
          );
        }).toList();
      },
      initialValue: ${param.type.name}.values[0],
      onSelected: (${param.type.name} value) {
        setState(() {
          ${param.name} = value;
          updateKey();
        });
      },
      child: new Text((${param.name} ?? 'null').toString()),
    )''';
  }

  // Handle callback parameters.
  if (_isCallbackParameter(param)) {
    return "new InfoText('Default implementation')";
  }

  // Handle parameters with a specified generator.
  ElementAnnotation generatorAnnotation = _getGenerator(param);
  if (generatorAnnotation != null) {
    DartObject generatorObj = generatorAnnotation.computeConstantValue();
    DartType generatorType = generatorObj.getField('type').toTypeValue();
    String methodName = generatorObj.getField('methodName').toStringValue();

    // Add the generator type to the list of additional imports and generators.
    _addImportForElement(additionalImports, generatorType.element);
    generators.add(generatorType);

    // The actual code to invoke (e.g. `modelFixtures.thread()`).
    String generatorInvocationCode =
        _getGeneratorInvocationCode(generatorType, methodName);

    // Place a button widget for regenerating the value.
    return '''new RegenerateButton(
      onPressed: () {
        setState(() {
          ${param.name} = $generatorInvocationCode;
          updateKey();
        });
      },
      codeToDisplay: '${_escapeQuotes(generatorInvocationCode)}',
    )''';
  }

  return "new InfoText('null (this type of parameter is not supported yet)')";
}

String _generateInitialValueCode(
  Set<String> additionalImports,
  Set<DartType> generators,
  WidgetSpecs specs,
  ParameterElement param,
) {
  // See if there is an example value specified.
  dynamic value = specs.getExampleValue(param);
  if (value != null) {
    switch (value.runtimeType) {
      case int:
      case bool:
      case double:
        return value.toString();
      case String:
        return "'''${_escapeQuotes(value.toString())}'''";
      default:
        return 'null';
    }
  }

  // Retrieve the config value associated with the specified config key.
  String configKey = specs.getConfigKey(param);
  if (configKey != null) {
    return "config.config.get('${_escapeQuotes(configKey)}')";
  }

  // TODO(youngseokyoon): See if the parameter type has a default constructor
  // that can be used.
  // if (param.type.element is ClassElement) {
  //   ClassElement type = param.type.element;
  //   if (type.constructors
  //       .any((ConstructorElement c) => c.isDefaultConstructor)) {
  //     return 'new ${param.type.name}()';
  //   }
  // }

  // Handle primitive types.
  switch (param.type.name) {
    case 'int':
      return '0';
    case 'bool':
      return 'false';
    case 'double':
      return '0.0';
    case 'String':
      return "''";
  }

  // Handle enum types.
  if (_isEnumParameter(param)) {
    return '${param.type.name}.values[0]';
  }

  // Handle callback parameters.
  if (_isCallbackParameter(param)) {
    FunctionTypedElement func = param.type.element;
    String functionName = '${specs.name}.${param.name}';

    // Print out all the parameter values to the console.
    if (func.parameters.isNotEmpty) {
      String paramList = func.parameters
          .map((ParameterElement p) => 'dynamic ${p.name}')
          .join(', ');
      String valueList =
          func.parameters.map((ParameterElement p) => p.name).join(', ');
      return "($paramList) => print('$functionName called "
          "with parameters: \${<dynamic>[$valueList]}')";
    }

    // If the callback function has no parameters, just say it was called.
    return "() => print('$functionName called')";
  }

  // Handle parameters with a specified generator.
  ElementAnnotation generatorAnnotation = _getGenerator(param);
  if (generatorAnnotation != null) {
    DartObject generatorObj = generatorAnnotation.computeConstantValue();
    DartType generatorType = generatorObj.getField('type').toTypeValue();
    String methodName = generatorObj.getField('methodName').toStringValue();

    // Place a button widget for regenerating the value.
    return _getGeneratorInvocationCode(generatorType, methodName);
  }

  // Otherwise, return 'null';
  return 'null';
}

/// Determines whether the provided parameter is of an enum type.
bool _isEnumParameter(ParameterElement param) {
  if (param?.type?.element is! ClassElement) {
    return false;
  }

  ClassElement paramType = param.type.element;
  return paramType.isEnum;
}

/// Determines whether the provided parameter represents a callback function.
///
/// We consider any function parameter with a void return type as a callback.
bool _isCallbackParameter(ParameterElement param) {
  if (param?.type?.element is! FunctionTypedElement) {
    return false;
  }

  FunctionTypedElement func = param.type.element;
  return func.returnType.isVoid;
}

/// Gets the @Generator annotation of the given parameter.
ElementAnnotation _getGenerator(ParameterElement param) {
  ElementAnnotation annotation;

  // An @Generator annotation on the parameter itself has a higher priority.
  annotation = getAnnotationWithName(param, 'Generator');
  if (annotation != null) {
    return annotation;
  }

  // Also see if the parameter type (class) has an @Generator annotation.
  annotation = getAnnotationWithName(param?.type?.element, 'Generator');
  return annotation;
}

/// Gets the code for invoking the generator.
String _getGeneratorInvocationCode(DartType generatorType, String methodName) {
  return '${lowerCamelize(generatorType.name)}.$methodName()';
}

/// Escape all single quotes in the given string with a leading backslash,
/// except for the ones already escaped.
String _escapeQuotes(String str) {
  return str?.replaceAllMapped(
    new RegExp(r"([^\\])'"),
    (Match m) => "${m.group(1)}\\\'",
  );
}

void _addImportForElement(Set<String> additionalImports, Element element) {
  String importUri = element?.librarySource?.uri?.toString();
  if (importUri != null && importUri != 'dart:core') {
    additionalImports.add(importUri);
  }
}
