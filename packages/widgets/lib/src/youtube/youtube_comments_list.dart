// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show JSON;

import 'package:flutter/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/youtube.dart';

import '../user/alphatar.dart';
import 'loading_state.dart';

final String _kApiBaseUrl = 'content.googleapis.com';

final String _kApiRestOfUrl = '/youtube/v3/commentThreads';

final String _kApiQueryParts = 'id,snippet';

// TODO(dayang): Render "one hour before.." style timestamps for comments
// https://fuchsia.atlassian.net/browse/SO-118

/// UI Widget that shows a list of top comments for a single Youtube video
class YoutubeCommentsList extends StatefulWidget {
  /// ID for given youtube video to render comments for
  final String videoId;

  /// Youtube API key needed to access the Youtube Public APIs
  final String apiKey;

  /// Constructor
  YoutubeCommentsList({
    Key key,
    @required this.videoId,
    @required this.apiKey,
  })
      : super(key: key) {
    assert(videoId != null);
    assert(apiKey != null);
  }

  @override
  _YoutubeCommentsListState createState() => new _YoutubeCommentsListState();
}

class _YoutubeCommentsListState extends State<YoutubeCommentsList> {
  /// Comments for given video
  List<VideoComment> _comments;

  /// Loading State for video comments
  LoadingState _loadingState = LoadingState.inProgress;

  Future<List<VideoComment>> _getCommentsData() async {
    Map<String, String> params = <String, String>{};
    params['videoId'] = config.videoId;
    params['key'] = config.apiKey;
    params['part'] = _kApiQueryParts;
    params['order'] = 'relevance';
    params['textFormat'] = 'plainText';

    Uri uri = new Uri.https(_kApiBaseUrl, _kApiRestOfUrl, params);
    http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      return null;
    }
    dynamic jsonData = JSON.decode(response.body);

    if (jsonData['items'] is List<dynamic>) {
      return jsonData['items']
          .map((dynamic json) => new VideoComment.fromJson(json))
          .toList();
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _getCommentsData().then((List<VideoComment> comments) {
      if (mounted) {
        if (comments == null) {
          setState(() {
            _loadingState = LoadingState.failed;
          });
        } else {
          setState(() {
            _loadingState = LoadingState.completed;
            _comments = comments;
          });
        }
      }
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _loadingState = LoadingState.failed;
        });
      }
    });
  }

  Widget _buildCommentFooter(VideoComment comment) {
    return new Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 4.0),
            child: new Icon(
              Icons.thumb_up,
              size: 14.0,
              color: Colors.grey[500],
            ),
          ),
          new Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: new Text(
              comment.likeCount > 0 ? '${comment.likeCount}' : '',
              style: new TextStyle(
                color: Colors.grey[500],
                fontSize: 12.0,
              ),
            ),
          ),
          new Container(
              margin: const EdgeInsets.only(right: 4.0),
              child: new Icon(
                Icons.comment,
                size: 14.0,
                color: Colors.grey[500],
              )),
          new Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: new Text(
              comment.totalReplyCount > 0 ? '${comment.totalReplyCount}' : '',
              style: new TextStyle(
                color: Colors.grey[500],
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    List<Widget> children = <Widget>[];
    _comments.forEach((VideoComment comment) {
      children.add(new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new Alphatar.fromNameAndUrl(
                name: comment.authorDisplayName,
                avatarUrl: comment.authorProfileImageUrl,
              ),
            ),
            new Flexible(
              flex: 1,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    comment.text,
                    softWrap: true,
                  ),
                  new Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    child: new Text(
                      comment.authorDisplayName,
                      style: new TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  _buildCommentFooter(comment),
                ],
              ),
            ),
          ],
        ),
      ));
    });
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget commentsList;
    switch (_loadingState) {
      case LoadingState.inProgress:
        commentsList = new Container(
          height: 100.0,
          child: new Center(
            child: new CircularProgressIndicator(
              value: null,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey[300]),
            ),
          ),
        );
        break;
      case LoadingState.completed:
        commentsList = _buildList();
        break;
      case LoadingState.failed:
        commentsList = new Container(
          height: 100.0,
          child: new Text('Comments Failed to Load'),
        );
        break;
    }
    return commentsList;
  }
}
