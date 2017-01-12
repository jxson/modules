// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/analyzer.dart';
import 'package:glob/glob.dart';
import 'package:source_span/source_span.dart';

import 'widget_specs.dart';

/// List of expected flutter widget superclass names.
///
/// Any direct subclasses of these classes will be considered custom flutter
/// widgets.
const List<String> _kFlutterWidgetSuperclasses = const <String>[
  'StatefulWidget',
  'StatelessWidget',
];

/// Extracts all the flutter widgets and their specs from the given package.
///
/// The dart files are assumed to be under the `lib` directory.
List<WidgetSpecs> extractWidgetSpecs(String packagePath) {
  // Look for all the dart code under the 'lib' directory.
  Glob pattern = new Glob('$packagePath/lib/**/*.dart');

  return pattern.listSync().expand(_extractFromDartFile).toList();
}

/// Extracts all the flutter widgets and their specs from the given dart file.
Iterable<WidgetSpecs> _extractFromDartFile(FileSystemEntity dartFile) {
  // Parse the given file.
  SourceFile source = new SourceFile(
    new File(dartFile.path).readAsStringSync(),
    url: new Uri.file(dartFile.path),
  );
  CompilationUnit cu = parseCompilationUnit(source.getText(0));

  // Collect all the classes declared in that file.
  _ClassVisitor classVisitor = new _ClassVisitor();
  cu.visitChildren(classVisitor);
  List<ClassDeclaration> classes = classVisitor.classes;

  // Find all the public flutter widgets, and then create widget specs for them.
  return classes
      .where(_isPublicWidget)
      .map(new _WidgetSpecsCreator(source))
      .toList();
}

/// Determines whether the given [ClassDeclaration] declares a public flutter
/// widget.
bool _isPublicWidget(ClassDeclaration c) {
  if (Identifier.isPrivateName(c.name.name)) {
    return false;
  }

  String superClassName = c?.extendsClause?.superclass?.name?.name;
  return _kFlutterWidgetSuperclasses.contains(superClassName);
}

/// A helper class for creating [WidgetSpecs] from [ClassDeclaration]s.
class _WidgetSpecsCreator {
  _WidgetSpecsCreator(this.source);

  final SourceFile source;

  /// Creates a new [WidgetSpecs] instance from the given [ClassDeclaration].
  ///
  /// The given [ClassDeclaration] should be a flutter widget class inheriting
  /// either `StatelessWidget` or `StatefulWidget`.
  WidgetSpecs call(ClassDeclaration c) {
    String name = c?.name?.name;
    String doc;

    // See if there is a documentation comment associated with this class.
    if (c?.documentationComment != null) {
      Comment comment = c.documentationComment;
      doc = _trimCommentPrefixes(source.getText(comment.offset, comment.end));
    }

    return new WidgetSpecs(
      name: name,
      doc: doc,
    );
  }

  /// Trims the leading document comment prefixes `/// ` from the raw comments.
  String _trimCommentPrefixes(String rawComment) {
    return rawComment
        .split('\n')
        .map((String line) => line.replaceFirst(new RegExp(r'^///[ \t]?'), ''))
        .join('\n');
  }
}

/// An [AstVisitor] for collecting all [ClassDeclaration]s from a given tree.
class _ClassVisitor extends GeneralizingAstVisitor<bool> {
  final List<ClassDeclaration> classes = <ClassDeclaration>[];

  @override
  bool visitClassDeclaration(ClassDeclaration node) {
    classes.add(node);
    return true;
  }
}
