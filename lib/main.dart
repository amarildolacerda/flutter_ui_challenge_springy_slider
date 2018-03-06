import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

const ACCENT_COLOR = const Color (0xFFFF6688);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Springy Slider',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        color: Colors.black,
        child: new Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 30.0, bottom: 20.0),
          child: new Container(
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
            ),
            child: new Column(
              children: [
                //-------- Top Bar -------
                new Container(
                  height: 60.0,
                  child: new Row(
                    children: [
                      new Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: new Icon(
                          Icons.menu,
                          color: ACCENT_COLOR,
                        ),
                      ),
                      new Expanded(child: new Container()),
                      new Padding(
                        padding: const EdgeInsets.only(right: 25.0),
                        child: new Text(
                          'SETTINGS',
                          style: const TextStyle(
                            color: ACCENT_COLOR,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //-------- Slider --------
                new Expanded(
                  child: new SpringySlider(),
                ),

                //------- Bottom Bar -----
                new Container(
                  height: 60.0,
                  color: ACCENT_COLOR,
                  child: new Row(
                    children: [
                      new Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: new Text(
                          'MORE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      new Expanded(child: new Container()),
                      new Padding(
                        padding: const EdgeInsets.only(right: 25.0),
                        child: new Text(
                          'STATS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            )
          ),
        ),
      ),
    );
  }
}

class SpringySlider extends StatefulWidget {

  final tickCount;

  SpringySlider({
    this.tickCount = 14,
  });

  @override
  _SpringySliderState createState() => new _SpringySliderState();
}

class _SpringySliderState extends State<SpringySlider> {

  Offset touchPoint;

  _onDrag(DragUpdateDetails details) {
    setState(() {
      touchPoint = details.globalPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onPanUpdate: _onDrag,
      child: new CustomPaint(
        painter: new SpringySliderPainter(
          color: ACCENT_COLOR,
          touchPoint: touchPoint,
        ),
        child: new Container(),
      )
    );
  }
}

class SpringySliderPainter extends CustomPainter {

  final Color color;
  final Offset touchPoint;
  final Paint sliderPaint;
  final Paint debugPaint;

  SpringySliderPainter({
    this.color = Colors.black,
    this.touchPoint,
  }) : sliderPaint = new Paint(), debugPaint = new Paint() {
    sliderPaint.color = this.color;
    sliderPaint.style = PaintingStyle.fill;

    debugPaint.color = Colors.black;
    debugPaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height));

    final Point rightPoint = new Point(size.width, size.height / 2);
    Point rightHandle;
    if (this.touchPoint == null) {
      rightHandle = new Point(
          2 * size.width / 3, size.height / 2 + 200.0);
    } else {
      rightHandle = new Point(touchPoint.dx, touchPoint.dy);
    }

    final Point leftPoint = new Point(-200.0, size.height / 4);

    final path = new Path();
    path.moveTo(rightPoint.x, rightPoint.y);
    path.quadraticBezierTo(rightHandle.x, rightHandle.y, leftPoint.x, leftPoint.y);
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, sliderPaint);

    canvas.drawCircle(new Offset(size.width, size.height / 2), 10.0, debugPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}