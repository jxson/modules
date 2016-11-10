// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is a template for the actual config.dart file, without all the
// actual configuration values. For now, this file contains the client id /
// secret values to be used for accessing Google APIs.
//
// To use the gallery app with real data for a logged-in user, first copy this
// file to "config.dart" in the same directory (which is also done by "make"
// command by default), and edit the "config.dart" to fill in the actual values
// in the _kConfigValues map at the bottom.
//
// The "config.dart" file is ignored by git, so your local changes would not be
// touched by git commands.

/// The default [ConfigProvider] instance that should be used by any callers.
const ConfigProvider kConfig = const ConfigProvider();

/// A wrapper class for providing local configurations, which are not meant to
/// be checked in to the source control.
class ConfigProvider {
  /// Default const constructor for creating an instance of [ConfigProvider].
  const ConfigProvider();

  /// Returns the String value associated with the given [key].
  ///
  /// Throws an [Exception] when the value for the given key is not defined.
  String get(String key) {
    // If the key is not defined at all, tell the user to update the config file
    // template.
    if (!_kConfigValues.containsKey(key)) {
      throw new Exception('The key "$key" is not defined. Make sure to copy '
          'the most recent version of "config.example.dart" file to '
          '"config.dart" and fill in the values locally in config.dart.');
    }

    String value = _kConfigValues[key];

    // If the key is defined but the value is null, tell the user to locally
    // fill in the value.
    if (value == null) {
      throw new Exception('The value of "$key" is not defined. '
          'Make sure to override the value in "config.dart" file locally');
    }

    return value;
  }
}

/// Local configuration data to be referenced by [ConfigProvider].
const Map<String, String> _kConfigValues = const <String, String>{
  /// Client ID for the GoogleAPI project.
  'client_id': null,

  /// Client secret for the GoogleAPI project.
  'client_secret': null,

  /// API key for Google Services (Map, Youtube...)
  'google_services_api_key': null,
};
