// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:auth/auth_credentials.dart';
import 'package:auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:flux/email.dart';
import 'package:models/email.dart';

import '../flux/gallery.dart';
import 'index.dart';

/// The root widget for the flux-based gallery screen.
class FluxGalleryScreen extends StoreWatcher {
  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(kGalleryStoreToken);
  }

  @override
  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    GalleryStore galleryStore = stores[kGalleryStoreToken];

    try {
      switch (galleryStore.route) {
        case '/':
          return new LoginScreen(
            clientId: galleryStore.clientId,
            clientSecret: galleryStore.clientSecret,
            refreshToken: galleryStore.refreshToken,
            onLoginSuccess: (AuthCredentials cred) {
              kGalleryActions.updateCredentials(cred);
              kEmailActions.fetchThreads(cred);
              kGalleryActions.navigateToListView();
            },
          );

        case '/email/list':
          return new EmailListScreen(onThreadSelect: (Thread t) {
            kGalleryActions.navigateToThreadView(t.id);
          });

        case '/email/thread':
          return new EmailThreadScreen(
            threadId: galleryStore.threadId,
            onThreadClose: (_) {
              kGalleryActions.popRoute();
            },
          );
      }

      return new ErrorScreen('Unknown route: ${galleryStore.route}');
    } catch (e) {
      return new ErrorScreen('Error occurred: $e');
    }
  }
}
