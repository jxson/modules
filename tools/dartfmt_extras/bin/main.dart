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

    // TODO(youngseokyoon): add import statement sorting logic here.
    // Ref: https://fuchsia.atlassian.net/browse/SO-41
    error = await processDoubleQuotes(cmd, dartFile, src) || error;
  });

  exitCode = error ? 1 : 0;
}

/// Check or fix the double quote issues.
Future<bool> processDoubleQuotes(Command cmd, File file, SourceFile src) async {
  CompilationUnit cu = parseCompilationUnit(src.getText(0));

  _DoubleQuoteVisitor visitor = new _DoubleQuoteVisitor(src);
  cu.accept(visitor);

  if (visitor.invalidNodes.isEmpty) {
    return false;
  }

  switch (cmd) {
    case Command.check:
      checkDoubleQuotes(src, visitor.invalidNodes);
      return true;

    case Command.fix:
      await fixDoubleQuotes(file, src, visitor.invalidNodes);
      break;
  }

  return false;
}

/// Report double quote issues.
void checkDoubleQuotes(SourceFile src, List<SingleStringLiteral> invalidNodes) {
  invalidNodes.forEach((SingleStringLiteral node) {
    print('${src.url}:${src.getLine(node.offset)}:\t$node');
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
