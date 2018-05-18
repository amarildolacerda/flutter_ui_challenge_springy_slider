import 'dart:ui';

import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Springy Slider',
      theme: new ThemeData(
        primaryColor: const Color(0xFFFF6688),
        scaffoldBackgroundColor: Colors.white,
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
            new Expanded(
              child: new SpringySlider(
                markCount: 12,
                positiveColor: Theme.of(context).primaryColor,
                negativeColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
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

class SpringySlider extends StatefulWidget {
  final int markCount;
  final Color positiveColor;
  final Color negativeColor;

  SpringySlider({
    this.markCount = 10,
    this.positiveColor,
    this.negativeColor,
  });

  @override
  _SpringySliderState createState() => new _SpringySliderState();
}

class _SpringySliderState extends State<SpringySlider> {
  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new SliderMarks(
          markCount: widget.markCount,
          color: widget.positiveColor,
          paddingTop: 50.0,
          paddingBottom: 50.0,
        ),
        new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return new ClipPath(
              clipper: new SliderClipper(),
              child: new Stack(
                children: <Widget>[
                  new Container(
                    color: widget.positiveColor,
                  ),
                  new SliderMarks(
                    markCount: widget.markCount,
                    color: widget.negativeColor,
                    paddingTop: 50.0,
                    paddingBottom: 50.0,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class SliderMarks extends StatelessWidget {
  final int markCount;
  final Color color;
  final double paddingTop;
  final double paddingBottom;

  SliderMarks({
    this.markCount,
    this.color,
    this.paddingTop,
    this.paddingBottom,
  });

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: new SliderMarksPainter(
        markCount: markCount,
        color: color,
        markThickness: 2.0,
        paddingRight: 20.0,
        paddingTop: paddingTop,
        paddingBottom: paddingBottom,
      ),
      child: new Container(),
    );
  }
}

class SliderMarksPainter extends CustomPainter {
  final double largeMarkWidth = 30.0;
  final double smallMarkWidth = 10.0;

  final int markCount;
  final Color color;
  final double markThickness;
  final double paddingTop;
  final double paddingBottom;
  final double paddingRight;
  final Paint markPaint;

  SliderMarksPainter({
    this.markCount,
    this.color,
    this.markThickness,
    this.paddingTop = 0.0,
    this.paddingBottom = 0.0,
    this.paddingRight = 0.0,
  }) : markPaint = new Paint()
          ..color = color
          ..strokeWidth = markThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final paintHeight = size.height - paddingTop - paddingBottom;
    final gap = paintHeight / (markCount - 1);

    for (int i = 0; i < markCount; ++i) {
      double markWidth = smallMarkWidth;
      if (i == 0 || i == markCount - 1) {
        markWidth = largeMarkWidth;
      } else if (i == 1 || i == markCount - 2) {
        markWidth = lerpDouble(smallMarkWidth, largeMarkWidth, 0.5);
      }

      double markY = i * gap + paddingTop;

      canvas.drawLine(
        new Offset(size.width - paddingRight - markWidth, markY),
        new Offset(size.width - paddingRight, markY),
        markPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class SliderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path compositePath = new Path();

    compositePath.addRect(
      new Rect.fromLTWH(
        0.0,
        size.height / 2,
        size.width,
        size.height / 2,
      ),
    );

    return compositePath;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
