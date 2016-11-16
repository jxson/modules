// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import './resolve.dart';

/// Configuration tooling.
class Config {
  String

  static Future<Config> load() async {

    // Config config = await Config.load();
    // String identifier = config.get('oauth_id');
    // String secret = config.get('oauth_secret');
    //
    // ClientId id = new ClientId(identifier, secret);
    // http.Client client = new http.Client();
    // List<String> scopes = <String>[
    //   'https://www.googleapis.com/auth/gmail.modify'
    // ];
    //
    // AccessCredentials credentials =
    //     await obtainAccessCredentialsViaUserConsent(id, scopes, client, _prompt);
    // client.close();
    //
    // config.put('oauth_token', credentials.accessToken.data);
    // config.put('oauth_token_expiry', credentials.accessToken.expiry);
    // config.put('oauth_refresh_token', credentials.accessToken.expiry);
    //
    // await config.save();
    //
    // print('updated: ${config.file}');


  }

  /// Get a value from the config.yaml file.
  static Future<String> get(String key) async {
    String filename = resolve('config.json');
    File file = new File(filename);

    if (!(await file.exists())) {
      await file.writeAsString('');
    }

    String contents = await file.readAsString();
    Map<String, String> map = new Map<String, String>();

    if (contents.isNotEmpty) {
      // dynamic data = yaml.loadYaml(contents);
      // data.forEach((String key, String value) {
      //   map[key] = value;
      // });
    }

    if (map[key] == null) {
      String message = '''Undefined config value "$key".

Please add an entry for "$key" to the config.yaml file:

    $filename

''';
      throw new StateError(message);
    }

    return map[key];
  }
}

//   String cwd = path.normalize(path.absolute('..'));
//   String dirname = path.join(cwd, 'service', 'lib', 'src', 'api');
//   Directory directory = new Directory(dirname);
//   if (!(await directory.exists())) {
//     await directory.create(recursive: true);
//   }
//
//   String filename = path.join(dirname, 'client.dart');
//   File file = new File(filename);
//   if (!(await file.exists())) {
//     await file.writeAsString('');
//   }
//
//   await file.writeAsString(source);
//
