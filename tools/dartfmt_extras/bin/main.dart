// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:analyzer/analyzer.dart';
import 'package:path/path.dart' as path;
import 'package:source_span/source_span.dart';

/// Commands supported in this util.
enum Command {
  /// Check the provided files and exit with 0 if they conform to the formatting
  /// guidelines. Exit with 1 otherwise.
  check,

  /// Fix the formatting issues.
  fix,
}

Future<Null> main(List<String> args) async {
  // Expect to get exactly one argument.
  if (args.length < 3) {
    stderr.writeln('Usage: pub run bin/main.dart '
        '<check|fix> <base_path> <list of dart files...>');
    exit(1);
  }

  // Command name check.
  if (!<String>['check', 'fix'].contains(args[0])) {
    stderr.writeln('The first argument should be either "check" or "fix".');
    exit(1);
  }
  Command cmd = args[0] == 'check' ? Command.check : Command.fix;

  bool error = false;
  String basePath = args[1];

  await Future.forEach(args.skip(2), (String relativePath) async {
    // Existence check.
    String fullPath = path.join(basePath, relativePath);
    File dartFile = new File(fullPath);
    if (!await dartFile.exists()) {
      stderr.writeln('The file ${args[0]} does not exist.');
      exit(1);
    }

    SourceFile src = new SourceFile(
      await dartFile.readAsString(),
      url: relativePath,
    );

    CompilationUnit cu = parseCompilationUnit(src.getText(0));
    error = await processDoubleQuotes(cmd, dartFile, src, cu) || error;
    error = await processImportDirectives(cmd, dartFile, src, cu) || error;
  });

  exitCode = error ? 1 : 0;
}

/// Check or fix the double quote issues.
Future<bool> processDoubleQuotes(
  Command cmd,
  File file,
  SourceFile src,
  CompilationUnit cu,
) async {
  _DoubleQuoteVisitor visitor = new _DoubleQuoteVisitor(src);
  cu.accept(visitor);

  if (visitor.invalidNodes.isEmpty) {
    return false;
  }

  switch (cmd) {
    case Command.check:
      reportDoubleQuotes(src, visitor.invalidNodes);
      return true;

    case Command.fix:
      await fixDoubleQuotes(file, src, visitor.invalidNodes);
      break;
  }

  return false;
}

/// Report double quote issues.
void reportDoubleQuotes(
    SourceFile src, List<SingleStringLiteral> invalidNodes) {
  invalidNodes.forEach((SingleStringLiteral node) {
    print('${src.url}:${src.getLine(node.offset)}: '
        'Prefer single quotes over double quotes: $node');
  });
}

/// Fix double quote issues.
Future<Null> fixDoubleQuotes(
  File file,
  SourceFile src,
  List<SingleStringLiteral> invalidNodes,
) async {
  // Get the original code as a String.
  String code = src.getText(0);

  // Replace the double quotes into single quotes.
  invalidNodes.forEach((SingleStringLiteral node) {
    int openingOffset = node.offset + (node.isRaw ? 1 : 0);
    code = code.replaceRange(
      openingOffset,
      openingOffset + (node.isMultiline ? 3 : 1),
      node.isMultiline ? "'''" : "'",
    );

    int closingOffset = node.contentsEnd;
    code = code.replaceRange(
      closingOffset,
      closingOffset + (node.isMultiline ? 3 : 1),
      node.isMultiline ? "'''" : "'",
    );
  });

  // Overwrite the source file.
  await file.writeAsString(code);
}

class _DoubleQuoteVisitor extends GeneralizingAstVisitor<bool> {
  _DoubleQuoteVisitor(this.src);

  final SourceFile src;
  final List<SingleStringLiteral> invalidNodes = <SingleStringLiteral>[];

  @override
  bool visitSingleStringLiteral(SingleStringLiteral node) {
    super.visitSingleStringLiteral(node);

    if (!isValidSingleStringLiteral(node)) {
      invalidNodes.add(node);
    }

    return true;
  }

  bool isValidSingleStringLiteral(SingleStringLiteral node) {
    return node.isSingleQuoted ||
        src.getText(node.contentsOffset, node.contentsEnd).contains("'");
  }
}

/// Check or fix the import statement ordering issues.
Future<bool> processImportDirectives(
  Command cmd,
  File file,
  SourceFile src,
  CompilationUnit cu,
) async {
  _ImportDirectiveVisitor visitor = new _ImportDirectiveVisitor(src);
  cu.accept(visitor);

  List<ImportDirective> imports = visitor.importDirectives;
  if (imports.isEmpty) {
    return false;
  }

  imports
      .sort((ImportDirective i1, ImportDirective i2) => i1.offset - i2.offset);

  // Start, end indices of the entire import block.
  int startIndex = imports.first.offset;
  int endIndex = imports.last.end;

  String actual = src.getText(startIndex, endIndex);
  String expected = _getOrderedImportDirectives(imports);

  if (actual == expected) {
    return false;
  }

  switch (cmd) {
    case Command.check:
      reportImportDirectives(src, startIndex, endIndex, actual, expected);
      return true;

    case Command.fix:
      await fixImportDirectives(file, src, startIndex, endIndex, expected);
      break;
  }

  return false;
}

/// Report import ordering issues.
void reportImportDirectives(
  SourceFile src,
  int startIndex,
  int endIndex,
  String actual,
  String expected,
) {
  print('${src.url}:${src.getLine(startIndex)}-${src.getLine(endIndex - 1)}: '
      'Order import directives properly.');
  print('== Actual ==');
  print(actual);
  print('== Expected ==');
  print(expected);
  print('==');
  print('');
}

/// Fix the import ordering issues.
Future<Null> fixImportDirectives(
  File file,
  SourceFile src,
  int startIndex,
  int endIndex,
  String expected,
) async {
  // Get the original code as a String.
  String code = src.getText(0);

  // Replace the import statements with the expected.
  code = code.replaceRange(startIndex, endIndex, expected);

  // Overwrite the source file.
  await file.writeAsString(code);
}

String _getOrderedImportDirectives(List<ImportDirective> imports) {
  Set<ImportDirective> importSet = imports.toSet();

  List<String> prefixes = <String>['dart:', 'package:', ''];
  return prefixes
      .map((String prefix) {
        // Get the group of import directives with the prefix, and sort them by
        // their uri.
        List<ImportDirective> group = importSet
            .where((ImportDirective i) => i.uri.stringValue.startsWith(prefix))
            .toList()
              ..sort((ImportDirective i1, ImportDirective i2) =>
                  i1.uri.stringValue.compareTo(i2.uri.stringValue));

        // Remove this group from the set, so that import directives are not
        // duplicated.
        importSet.removeAll(group);

        // Join the import directives with a newline character.
        return group.join('\n');
      })
      // Remove any empty groups.
      .where((String s) => s.isNotEmpty)
      // There should be one empty line between two import groups.
      .join('\n\n');
}

class _ImportDirectiveVisitor extends GeneralizingAstVisitor<bool> {
  _ImportDirectiveVisitor(this.src);

  final SourceFile src;
  final List<ImportDirective> importDirectives = <ImportDirective>[];

  @override
  bool visitImportDirective(ImportDirective node) {
    importDirectives.add(node);
    return true;
  }
}
