// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:application.lib.app.dart/app.dart';
import 'package:application.services/service_provider.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modular.services.story/module.fidl.dart';
import 'package:apps.modular.services.story/story.fidl.dart';
import 'package:config_flutter/config.dart';
import 'package:flutter/material.dart';
import 'package:lib.fidl.dart/bindings.dart';
import 'package:widgets/youtube.dart';

final ApplicationContext _context = new ApplicationContext.fromStartupInfo();

final GlobalKey<HomeScreenState> _kHomeKey = new GlobalKey<HomeScreenState>();

// This module expects to obtain the youtube video id string through the link
// provided from the parent, in the following document id / property key.
// The JSON string in the Link looks something like this:
// { "youtube-doc" : { "youtube-video-id" : "https://www.youtube.com/blah" } }
// TODO(youngseokyoon): add this information to the module manifest.
final String _kYoutubeDocRoot = 'youtube-doc';
final String _kYoutubeVideoIdKey = 'youtube-video-id';

ModuleImpl _module;

// The youtube video id.
String _videoId;

// The youtube api key.
String _apiKey;

void _log(String msg) {
  print('[youtube_related_videos] $msg');
}

/// An implementation of the [LinkWatcher] interface.
class LinkWatcherImpl extends LinkWatcher {
  final LinkWatcherBinding _binding = new LinkWatcherBinding();

  /// Gets the [InterfaceHandle] for this [LinkWatcher] implementation.
  ///
  /// The returned handle should only be used once.
  InterfaceHandle<LinkWatcher> getHandle() => _binding.wrap(this);

  /// Correctly close the Link Binding
  void close() => _binding.close();

  @override
  void notify(String json) {
    _log('LinkWatcherImpl::notify call');

    final dynamic doc = JSON.decode(json);
    if (doc is! Map ||
        doc[_kYoutubeDocRoot] is! Map ||
        doc[_kYoutubeDocRoot][_kYoutubeVideoIdKey] is! String) {
      _log('No youtube key found in json.');
      return;
    }

    _videoId = doc[_kYoutubeDocRoot][_kYoutubeVideoIdKey];

    _log('_videoId: $_videoId');
    _kHomeKey.currentState?.updateUI();
  }
}

/// An implementation of the [Module] interface.
class ModuleImpl extends Module {
  final ModuleBinding _binding = new ModuleBinding();

  /// The [LinkProxy] from which this module gets the youtube video id.
  final LinkProxy link = new LinkProxy();

  /// Bind an [InterfaceRequest] for a [Module] interface to this object.
  void bind(InterfaceRequest<Module> request) {
    _binding.bind(this, request);
  }

  final LinkWatcherImpl _linkWatcher = new LinkWatcherImpl();

  @override
  void initialize(
    InterfaceHandle<Story> storyHandle,
    InterfaceHandle<Link> linkHandle,
    InterfaceHandle<ServiceProvider> incomingServicesHandle,
    InterfaceRequest<ServiceProvider> outgoingServices,
  ) {
    _log('ModuleImpl::initialize call');

    // Bind the link handle and register the link watcher.
    link.ctrl.bind(linkHandle);
    link.watchAll(_linkWatcher.getHandle());
  }

  @override
  void stop(void callback()) {
    _log('ModuleImpl::stop call');
    _linkWatcher.close();
    link.ctrl.close();
    callback();
  }
}

/// Main screen for this module.
class HomeScreen extends StatefulWidget {
  /// Creates a new instance of [HomeScreen].
  HomeScreen({Key key}) : super(key: key);

  @override
  HomeScreenState createState() => new HomeScreenState();
}

/// State class for the main screen widget.
class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      alignment: FractionalOffset.center,
      constraints: const BoxConstraints.expand(),
      child: new Material(
        child: _videoId != null && _apiKey != null
            ? new ScrollableViewport(
                child: new YoutubeRelatedVideos(
                  videoId: _videoId,
                  apiKey: _apiKey,
                ),
              )
            : new CircularProgressIndicator(),
      ),
    );
  }

  /// Convenient method for other entities to call setState to cause UI updates.
  void updateUI() {
    _log('updateUI call');
    setState(() {});
  }
}

Future<Null> _readAPIKey() async {
  Config config = await Config.read('assets/config.json');
  String googleApiKey = config.get('google_api_key');
  if (googleApiKey == null) {
    _log('"google_api_key" value is not specified in config.json.');
  } else {
    _apiKey = googleApiKey;
    _kHomeKey.currentState?.updateUI();
  }
}

/// Main entry point to the email folder list module.
void main() {
  _log('Module started with context: $_context');

  /// Add [ModuleImpl] to this application's outgoing ServiceProvider.
  _context.outgoingServices.addServiceForName(
    (InterfaceRequest<Module> request) {
      _log('Received binding request for Module');
      if (_module != null) {
        _log('Module interface can only be provided once. Rejecting request.');
        request.channel.close();
        return;
      }
      _module = new ModuleImpl()..bind(request);
    },
    Module.serviceName,
  );

  _readAPIKey();

  runApp(new MaterialApp(
    title: 'Youtube Related Videos',
    home: new HomeScreen(key: _kHomeKey),
    theme: new ThemeData(primarySwatch: Colors.blue),
    debugShowCheckedModeBanner: false,
  ));
}
