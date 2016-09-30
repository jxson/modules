// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Represents the auth credentials returned after OAuth flow.
/// (See: https://developers.google.com/identity/protocols/OAuth2InstalledApp)
class AuthCredentials {
  /// The token that can be sent to a Google API.
  final String accessToken;

  /// A JWT that contains identity information about the user that is digitally
  /// signed by Google. If your request included an identity scope such as
  /// openid, profile, or email.
  final String idToken;

  /// A token that may be used to obtain a new access token, included by default
  /// for installed applications. Refresh tokens are valid until the user
  /// revokes access.
  final String refreshToken;

  /// The remaining lifetime of the access token.
  final int expiresIn;

  /// Identifies the type of token returned. Currently, this field always has
  /// the value Bearer.
  final String tokenType;

  /// Creates a new [AuthCredentials] instance with the given values.
  AuthCredentials({
    this.accessToken,
    this.idToken,
    this.refreshToken,
    this.expiresIn,
    this.tokenType,
  });
}
