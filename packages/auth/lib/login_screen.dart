// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:io';

import 'package:flutter/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import 'auth_credentials.dart';

typedef void _UserPromptFn(String uri);

/// Callback function to be called when the login attempt is successful.
typedef void OnLoginSuccess(AuthCredentials credentials);

const String _userPromptMessage = '''
Auth URL is copied to the clipboard.
Please open it from a browser app on the same device.

Detailed instructions for the first time use (for Android N):
1. Open Chrome app on your device.
2. While the Chrome app is on the front screen, long-press the square button to
   activate the split-screen mode of Android N.
3. Choose this Gallery app from the new split screen to place Chrome and Gallery
   side by side.
4. Press the 'Login' button from the Gallery
5. Go to Chrome and paste the URL into the omni box.
6. Proceed with the OAuth flow.
7. Come back to the Gallery app to proceed to the logged-in experience.
''';

/// Login screen of the flutter email app, which takes care of the OAuth flow.
/// If the login is successful, the screen transitions to the inbox view.
class LoginScreen extends StatefulWidget {
  /// Creates an instance of [LoginScreen].
  LoginScreen(
      {Key key,
      @required this.clientId,
      @required this.clientSecret,
      this.refreshToken,
      this.onLoginSuccess})
      : super(key: key) {
    assert(clientId != null);
    assert(clientSecret != null);
  }

  /// Client ID value required for OAuth.
  final String clientId;

  /// Client Secret value required for OAuth.
  final String clientSecret;

  /// Refresh token to be used.
  final Future<String> refreshToken;

  /// Reference to the [OnLoginSuccess] callback function.
  final OnLoginSuccess onLoginSuccess;

  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String baseAuthUri =
      'https://accounts.google.com/o/oauth2/v2/auth';

  bool _loggingIn;
  bool _loginEnabled;
  String _prompt;

  @override
  void initState() {
    super.initState();

    if (config.refreshToken == null) {
      _enableLoginUI();
      return;
    }

    _loggingIn = true;
    _loginEnabled = false;

    // If the refresh token is provided, use that token to obtain the auth
    // credentials.
    // TODO(youngseokyoon): make it possible to skip the login screen at all.
    config.refreshToken.then((String refreshToken) {
      if (!mounted) {
        return;
      }

      if (refreshToken != null) {
        // If the refresh token is provided, try to obtain the access token
        // using the refresh token.
        _obtainAuthCredentialsWithRefreshToken(refreshToken)
            .then((AuthCredentials credentials) {
          if (!mounted) {
            return;
          }

          setState(() {
            _loggingIn = false;
            _loginEnabled = false;
            _prompt = 'Successfully logged in!';
          });
          config.onLoginSuccess(credentials);
        }).catchError((Exception e) {
          // If the process was not successful, fall back to the normal login.
          _enableLoginUI();
        });
      } else {
        // If the refresh token is not available, just enable the login feature.
        _enableLoginUI();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget progress =
        _loggingIn ? new LinearProgressIndicator() : new SizedBox(height: 6.0);

    VoidCallback onLoginButtonPressed = _loginEnabled
        ? () {
            setState(() {
              _loggingIn = true;
            });
            _login(_promptAuthUri, config.onLoginSuccess);
          }
        : null;

    return new Container(
      alignment: FractionalOffset.center,
      child: new Column(
        children: <Widget>[
          progress,
          new Flexible(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(_prompt),
                new SizedBox(height: 10.0),
                new RaisedButton(
                  onPressed: onLoginButtonPressed,
                  child: new Text('Login'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _promptAuthUri(String authUri) {
    if (mounted) {
      setState(() {
        _prompt = _userPromptMessage;
      });
    }

    Clipboard.setClipboardData(new ClipboardData.init(authUri));
  }

  void _enableLoginUI() {
    if (!mounted) {
      return;
    }

    setState(() {
      _loggingIn = false;
      _loginEnabled = true;
      _prompt = '';
    });
  }

  Future<Null> _login(
      _UserPromptFn userPrompt, OnLoginSuccess onLoginSuccess) async {
    AuthCredentials credentials = await _runAuthCodeLoopbackFlow(userPrompt);

    if (mounted) {
      setState(() {
        _loggingIn = false;
        _loginEnabled = false;
        _prompt = 'Successfully logged in!';
      });
    }

    if (onLoginSuccess != null) {
      onLoginSuccess(credentials);
    }
  }

  Future<AuthCredentials> _runAuthCodeLoopbackFlow(
      _UserPromptFn userPrompt) async {
    HttpServer server = await HttpServer.bind('localhost', 0);
    DateFormat format = new DateFormat('yyyy-MM-dd-HH-mm-ss');

    try {
      String redirectionUri = 'http://localhost:${server.port}';
      String state = 'authcodestate-${format.format(new DateTime.now())}';
      Map<String, String> queryParams = <String, String>{
        'response_type': 'code',
        'client_id': config.clientId,
        'redirect_uri': redirectionUri,
        // For more details of the scopes:
        // https://developers.google.com/gmail/api/auth/scopes
        'scope': 'https://www.googleapis.com/auth/gmail.modify',
        'state': state,
      };

      String encodedQueryParams = queryParams.keys
          .map((String k) => '$k=${Uri.encodeQueryComponent(queryParams[k])}')
          .join('&');

      String authUri = '$baseAuthUri?$encodedQueryParams';

      // Prompt the user where to go.
      userPrompt(authUri);

      // Wait for the loopback request.
      HttpRequest request = await server.first;

      try {
        // Check for some error conditions.
        if (request.method != 'GET') {
          throw new Exception('Expected GET method, but got ${request.method}');
        }

        Uri uri = request.uri;
        if (state != uri.queryParameters['state']) {
          // This check is currently off to make it easier to get through OAuth
          // even when the flutter app restarts.
          // TODO(youngseokyoon): revive this check back.
          //
          // throw new Exception('State did not match!');
        }

        String error = uri.queryParameters['error'];
        if (error != null) {
          throw new Exception('Error returned: $error');
        }

        String authCode = uri.queryParameters['code'];
        if (authCode == null || authCode.isEmpty) {
          throw new Exception('Empty auth code returned.');
        }

        // Now we have the auth code. Send a response page and return.
        request.response
          ..statusCode = 200
          ..headers.set('content-type', 'text/html; charset=UTF-8')
          ..write('''
<!DOCTYPE html>

<html>
<head>
  <title>Authorization succeeded.</title>
</head>
<body>
  This window can be closed now.
</body>
</html>''');

        await request.response.close();

        return await _obtainAuthCredentialsWithAuthCode(
            authCode, redirectionUri);
      } catch (e) {
        request.response.statusCode = 500;
        await request.response.close().catchError((_) {});
        rethrow;
      }
    } finally {
      await server.close();
    }
  }

  Future<AuthCredentials> _obtainAuthCredentialsWithAuthCode(
    String authCode,
    String redirectionUri,
  ) async {
    Map<String, String> additionalParams = <String, String>{
      'code': authCode,
      'redirect_uri': redirectionUri,
      'grant_type': 'authorization_code',
    };

    return await _obtainAuthCredentials(additionalParams, null);
  }

  Future<AuthCredentials> _obtainAuthCredentialsWithRefreshToken(
    String refreshToken,
  ) async {
    Map<String, String> additionalParams = <String, String>{
      'refresh_token': refreshToken,
      'grant_type': 'refresh_token',
    };

    return await _obtainAuthCredentials(additionalParams, refreshToken);
  }

  Future<AuthCredentials> _obtainAuthCredentials(
    Map<String, String> additionalParams,
    String refreshToken,
  ) async {
    Uri tokenUri = new Uri(
      scheme: 'https',
      host: 'www.googleapis.com',
      path: '/oauth2/v4/token',
    );

    Map<String, String> body = <String, String>{
      'client_id': config.clientId,
      'client_secret': config.clientSecret,
    }..addAll(additionalParams);

    http.Response response = await http.post(tokenUri, body: body);
    if (response.statusCode != 200) {
      throw new Exception('Failed to obtain the auth credentials.');
    }

    dynamic jsonResponse = JSON.decode(response.body);
    return new AuthCredentials(
      accessToken: jsonResponse['access_token'],
      idToken: jsonResponse['id_token'],
      refreshToken: refreshToken ?? jsonResponse['refresh_token'],
      expiresIn: jsonResponse['expires_in'],
      tokenType: jsonResponse['token_type'],
    );
  }
}
