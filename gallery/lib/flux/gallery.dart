// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:auth/auth_credentials.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:util/local_storage.dart';

import '../src/config.dart';

/// A collection of available actions on the [GalleryStore].
class GalleryActions {
  /// Pushes the provided route.
  final Action<String> pushRoute = new Action<String>();

  /// Pops the route.
  final Action<Null> popRoute = new Action<Null>();

  /// Navigates to the email inbox view.
  final Action<Null> navigateToInboxView = new Action<Null>();

  /// Navigates to the email thread view of the given thread id.
  final Action<String> navigateToThreadView = new Action<String>();

  /// Updates the auth credentials to be used for accessing the email server.
  final Action<AuthCredentials> updateCredentials =
      new Action<AuthCredentials>();

  /// Updates the current thread id value.
  final Action<String> updateThreadId = new Action<String>();
}

/// A [Store] class for the gallery app which contains the routing information
/// and other data such as auth credentials.
class GalleryStore extends Store {
  /// Creates a new instance of [GalleryStore].
  ///
  /// Action handlers are registered within this constructor body.
  GalleryStore(this.actions) {
    triggerOnAction(actions.pushRoute, (String route) {
      _routeStack.add(route);
    });

    triggerOnAction(actions.popRoute, (_) {
      _routeStack.removeLast();
    });

    triggerOnAction(actions.navigateToInboxView, (_) {
      _routeStack.add('/email/inbox');
    });

    triggerOnAction(actions.navigateToThreadView, (String threadId) {
      _routeStack.add('/email/thread');
      _threadId = threadId;
    });

    triggerOnAction(actions.updateCredentials, (AuthCredentials cred) {
      _credentials = cred;
      localStorage.put('refresh_token', cred.refreshToken);
    });

    triggerOnAction(actions.updateThreadId, (String threadId) {
      _threadId = threadId;
    });
  }

  /// [GalleryActions] instance associated with this [GalleryStore].
  final GalleryActions actions;

  /// Gets the [AuthCredentials] object.
  AuthCredentials get credentials => _credentials;
  AuthCredentials _credentials;

  /// Client ID value for the Google APIs project.
  String get clientId => kConfig.get('client_id');

  /// Client secret value for the Google APIs project.
  String get clientSecret => kConfig.get('client_secret');

  /// An async getter for the refresh token value.
  Future<String> get refreshToken async =>
      await localStorage.get('refresh_token');

  /// Gets the current route.
  String get route => _routeStack.last;
  final List<String> _routeStack = <String>['/'];

  /// Gets the current thread id.
  String get threadId => _threadId;
  String _threadId;
}

/// Global [GalleryActions] instance for the global [GalleryStore].
final GalleryActions kGalleryActions = new GalleryActions();

/// Global [StoreToken] for the [GalleryStore].
final StoreToken kGalleryStoreToken =
    new StoreToken(new GalleryStore(kGalleryActions));
