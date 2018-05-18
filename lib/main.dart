import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Springy Slider',
      theme: new ThemeData(
        primaryColor: const Color(0xFFFF6688),
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _buildTextButton(String title, bool isOnLight) {
    return new FlatButton(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: new Text(
        title,
        style: new TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: isOnLight ? Theme.of(context).primaryColor : Colors.white,
        ),
      ),
      onPressed: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ClipRRect(
      borderRadius: new BorderRadius.circular(15.0),
      child: new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          iconTheme: new IconThemeData(
            color: Theme.of(context).primaryColor,
          ),
          elevation: 0.0,
          leading: new IconButton(
            icon: new Icon(
              Icons.menu,
            ),
            onPressed: () {},
          ),
          actions: <Widget>[
            _buildTextButton('SETTINGS', true),
          ],
        ),
        body: new Column(
          children: <Widget>[
            new Expanded(child: new Container()),
            new Container(
              color: Theme.of(context).primaryColor,
              child: new Row(
                children: <Widget>[
                  _buildTextButton('MORE', false),
                  new Expanded(child: new Container()),
                  _buildTextButton('STATS', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
