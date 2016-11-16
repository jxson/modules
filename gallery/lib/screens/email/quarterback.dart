// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:models/email.dart';

import '../../flux/gallery.dart';
import 'inbox.dart';
import 'menu.dart';
import 'thread.dart';

/// A screen demonstrating what the email quarterback module should look like.
///
/// This screen has three columns as a typical email client in landscape mode:
/// folder list, thread list, and thread details.
class EmailQuarterbackModule extends StoreWatcher {
  /// Create a new [EmailQuarterbackModule] instance.
  EmailQuarterbackModule({Key key}) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(kGalleryStoreToken);
  }

  @override
  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    GalleryStore galleryStore = stores[kGalleryStoreToken];

    // The container below should ideally be a ChildView.
    Widget menu = new Container(
      constraints: new BoxConstraints.loose(new Size.fromWidth(280.0)),
      child: new EmailMenuScreen(),
    );

    Widget inbox = new Container(
      margin: new EdgeInsets.symmetric(horizontal: 4.0),
      child: new Material(
        elevation: 2,
        // The container below should ideally be a ChildView.
        child: new Container(
          alignment: FractionalOffset.topCenter,
          constraints: new BoxConstraints.loose(new Size.fromWidth(400.0)),
          decoration: new BoxDecoration(backgroundColor: Colors.white),
          child: new EmailInboxScreen(
            onThreadSelect: (Thread t) =>
                galleryStore.actions.updateThreadId(t.id),
            selectedThreadId: galleryStore.threadId,
          ),
        ),
      ),
    );

    Widget thread = new Flexible(
      flex: 1,
      // The container below should ideally be a ChildView.
      child: new Container(
        child: galleryStore.threadId != null
            ? new EmailThreadScreen(
                threadId: galleryStore.threadId,
                onThreadClose: (_) {},
              )
            : null,
      ),
    );

    List<Widget> columns = <Widget>[menu, inbox, thread];
    return new Material(
      color: Colors.white,
      child: new Row(children: columns),
    );
  }
}
