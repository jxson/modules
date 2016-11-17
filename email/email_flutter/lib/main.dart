import 'dart:async';
import 'dart:convert' show JSON;

import 'package:email_service/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(new _MyApp());
}

class _MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting
        // the app, try changing the primarySwatch below to Colors.green
        // and press "r" in the console where you ran "flutter run".
        // We call this a "hot reload". Notice that the counter didn't
        // reset back to zero -- the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new _MyHomePage(title: 'Email Flutter App'),
    );
  }
}

class _MyHomePage extends StatefulWidget {
  _MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful,
  // meaning that it has a State object (defined below) that contains
  // fields that affect how it looks.

  // This class is the configuration for the state. It holds the
  // values (in this case the title) provided by the parent (in this
  // case the App widget) and used by the build method of the State.
  // Fields in a Widget subclass are always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  List<api.Thread> _threads = new List<api.Thread>();

  @override
  void initState() {
    rootBundle.loadString('assets/config.json').then((String data) {
      dynamic map = JSON.decode(data);

      api.Client client = api.client(
          id: map['oauth_id'],
          secret: map['oauth_secret'],
          token: map['oauth_token'],
          expiry: DateTime.parse(map['oauth_token_expiry']),
          refreshToken: map['oauth_refresh_token']);

      api.GmailApi gmail = new api.GmailApi(client);
      return load(gmail);
    }).catchError((Error error) {
      print('Error loading config file: $error');
    });

    super.initState();
  }

  Future<Null> load(api.GmailApi gmail) async {
    api.ListThreadsResponse response = await gmail.users.threads.list('me');
    setState(() => _threads = response.threads);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance
    // as done by the _incrementCounter method above.
    // The Flutter framework has been optimized to make rerunning
    // build methods fast, so that you can just rebuild anything that
    // needs updating rather than having to individually change
    // instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that
        // was created by the App.build method, and use it to set
        // our appbar title.
        title: new Text(config.title),
      ),
      body: new MaterialList(
        type: MaterialListType.twoLine,
        children: _threads.map((api.Thread thread) {
          return new ListItem(
            title: new Text(thread.id),
            subtitle: new Text(thread.snippet),
          );
        }),
      ), // This trailing comma tells the Dart formatter to use
      // a style that looks nicer for build methods.
    );
  }
}
