// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:models/usps.dart';
import 'package:xml/xml.dart' as xml;

final String _kApiBaseUrl = 'production.shippingapis.com';

final String _kApiRestOfUrl = 'ShippingApi.dll';

const TextStyle _entryTextStyle = const TextStyle(
  fontSize: 12.0,
);

/// Callback function signature for selecting a location to focus on
typedef void LocationSelectCallback(String location);

/// Represents the state of data loading
enum LoadingState {
  /// Still fetching data
  inProgress,

  /// Data has completed loading
  completed,

  /// Data failed to load
  failed,
}

/// UI Widget that tenders USPS tracking information for given package
class TrackingStatus extends StatefulWidget {
  /// API key for USPS APIs
  final String apiKey;

  /// USPS tracking code for given package
  final String trackingCode;

  /// Callback for selecting a location
  final LocationSelectCallback onLocationSelect;

  /// Constructor
  TrackingStatus({
    Key key,
    @required this.apiKey,
    @required this.trackingCode,
    this.onLocationSelect,
  })
      : super(key: key) {
    assert(apiKey != null);
    assert(trackingCode != null);
  }

  @override
  _TrackingStatusState createState() => new _TrackingStatusState();
}

class _TrackingStatusState extends State<TrackingStatus> {
  /// Tracking Entries retrieved from the USPS API
  List<TrackingEntry> _trackingEntries;

  TrackingEntry _selectedEntry;

  /// Loading State for Tracking Data
  LoadingState _loadingState = LoadingState.inProgress;

  /// Make request to USPS API to retrieve tracking data for given tracking code
  Future<List<TrackingEntry>> _getTrackingData() async {
    Map<String, String> params = <String, String>{};
    params['API'] = 'TrackV2';
    params['XML'] = '''
    <TrackFieldRequest USERID="${config.apiKey}">
      <TrackID ID="${config.trackingCode}">
      </TrackID>
    </TrackFieldRequest>
    ''';

    Uri uri = new Uri.http(_kApiBaseUrl, _kApiRestOfUrl, params);
    http.Response response = await http.get(uri);
    xml.XmlDocument xmlData = xml.parse(response.body);

    Iterable<xml.XmlElement> topLevelElements =
        xmlData.findAllElements('TrackInfo');
    if (topLevelElements.isNotEmpty) {
      List<TrackingEntry> entries = <TrackingEntry>[];
      topLevelElements.first.children.forEach((xml.XmlNode node) {
        entries.add(new TrackingEntry.fromXML(node));
      });
      return entries;
    } else {
      return null;
    }
  }

  void _handleEntrySelect(TrackingEntry entry) {
    setState(() {
      _selectedEntry = entry;
    });
    config.onLocationSelect?.call(entry.fullLocation);
  }

  @override
  void initState() {
    super.initState();
    _getTrackingData().then((List<TrackingEntry> entries) {
      if (mounted) {
        setState(() {
          if (entries == null) {
            _loadingState = LoadingState.failed;
          } else {
            _loadingState = LoadingState.completed;
            _trackingEntries = entries;
            _handleEntrySelect(entries.first);
          }
        });
      }
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _loadingState = LoadingState.failed;
        });
      }
    });
  }

  Widget _buildTrackingEntry(TrackingEntry entry) {
    return new Material(
      color: entry == _selectedEntry ? Colors.grey[200] : Colors.white,
      child: new InkWell(
        onTap: () {
          _handleEntrySelect(entry);
        },
        child: new Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 12.0,
          ),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Flexible(
                flex: 2,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      entry.date,
                      style: _entryTextStyle,
                    ),
                    new Text(
                      entry.time,
                      style: _entryTextStyle,
                    ),
                  ],
                ),
              ),
              new Flexible(
                flex: 2,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      entry.city,
                      style: _entryTextStyle,
                    ),
                    new Text(
                      '${entry.state}, ${entry.zipCode}',
                      style: _entryTextStyle,
                    ),
                  ],
                ),
              ),
              new Flexible(
                flex: 3,
                child: new Text(
                  entry.entryDetails,
                  style: _entryTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingEntryList() {
    TextStyle headerStyle = new TextStyle(
      color: Colors.white,
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
    );

    List<Widget> children = <Widget>[];
    children.add(new Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 12.0,
      ),
      decoration: new BoxDecoration(
        backgroundColor: Colors.indigo[600],
      ),
      child: new Row(
        children: <Widget>[
          new Flexible(
            flex: 2,
            child: new Text(
              'DATE/TIME',
              style: headerStyle,
            ),
          ),
          new Flexible(
            flex: 2,
            child: new Text(
              'LOCATION',
              style: headerStyle,
            ),
          ),
          new Flexible(
            flex: 3,
            child: new Text(
              'STATUS',
              style: headerStyle,
            ),
          )
        ],
      ),
    ));

    _trackingEntries.forEach((TrackingEntry entry) {
      children.add(_buildTrackingEntry(entry));
    });

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget entryList;
    switch (_loadingState) {
      case LoadingState.inProgress:
        entryList = new Container(
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
        entryList = _buildTrackingEntryList();
        break;
      case LoadingState.failed:
        entryList = new Container(
          height: 100.0,
          child: new Text('Tracking Data Failed to Load'),
        );
        break;
    }
    return entryList;
  }
}
