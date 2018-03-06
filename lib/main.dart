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
            child: new ClipRRect(
              borderRadius: new BorderRadius.circular(15.0),
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
                    child: new SpringySlider(
                      sliderPercent: 0.5,
                    ),
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
              ),
            )
          ),
        ),
      ),
    );
  }
}

class SpringySlider extends StatefulWidget {

  final tickCount;
  final sliderPercent;

  SpringySlider({
    this.tickCount = 14,
    this.sliderPercent = 0.0,
  });

  @override
  _SpringySliderState createState() => new _SpringySliderState();
}

class _SpringySliderState extends State<SpringySlider> {

  double sliderPercent;
  double sliderPercentOnStartDrag;
  Offset touchStart;
  Offset touchPoint;

  @override
  void initState() {
    sliderPercent = widget.sliderPercent;
  }

  _onStartDrag(DragStartDetails details) {
    touchStart = (context.findRenderObject() as RenderBox)
        .globalToLocal(details.globalPosition);

    sliderPercentOnStartDrag = sliderPercent;
  }

  _onDrag(DragUpdateDetails details) {
    setState(() {
      touchPoint = (context.findRenderObject() as RenderBox)
          .globalToLocal(details.globalPosition);

      final dragVector = touchStart.dy - touchPoint.dy;
      final normalizedDragVector = (dragVector / context.size.height).clamp(-1.0, 1.0);
      sliderPercent = (sliderPercentOnStartDrag + normalizedDragVector).clamp(0.0, 1.0);
    });
  }

  _onDragEnd(DragEndDetails details) {
    setState(() {
      touchStart = null;
      touchPoint = null;
      sliderPercentOnStartDrag = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onPanStart: _onStartDrag,
      onPanUpdate: _onDrag,
      onPanEnd: _onDragEnd,
      child: new CustomPaint(
        painter: new SpringySliderPainter(
          color: ACCENT_COLOR,
          sliderPercent: sliderPercent,
          prevSliderPercent: sliderPercentOnStartDrag ?? sliderPercent,
          touchPoint: touchPoint,
        ),
        child: new Container(),
      )
    );
  }
}

class SpringySliderPainter extends CustomPainter {

  final double sliderPercent; // [0.0, 1.0]
  final double prevSliderPercent; // [0.0, 1.0]
  final Color color;
  final Offset touchPoint;
  final Paint sliderPaint;
  final Paint debugPaint;

  SpringySliderPainter({
    this.sliderPercent = 0.0,
    this.prevSliderPercent = 0.0,
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

    print('Slider Percent: $sliderPercent, Prev Percent: $prevSliderPercent');
    final sliderValueY = size.height - (size.height * sliderPercent);
    final prevSliderValueY = size.height - (size.height * prevSliderPercent);

    Point leftPoint, midPoint, rightPoint;

    leftPoint = new Point(0.0, prevSliderValueY);
    rightPoint = new Point(size.width, prevSliderValueY);

    if (null != touchPoint) {
      midPoint = new Point(touchPoint.dx, sliderValueY);
    } else {
      midPoint = new Point(size.width / 2, prevSliderValueY);
    }

//    Point rightHandle;
//    if (this.touchPoint == null) {
//      print(' - Painting straight line.');
//      rightHandle = new Point(size.width - 10.0, sliderValueY);
//    } else {
//      print(' - Painting curve');
//      final handleY = (700.0 * (prevSliderPercent - sliderPercent) + rightPoint.y).clamp(0.0, size.height);
//      rightHandle = new Point(touchPoint.dx, handleY);
//    }


    final path = new Path();
    path.moveTo(midPoint.x, midPoint.y);
    path.quadraticBezierTo(midPoint.x - 75.0, midPoint.y, leftPoint.x, leftPoint.y);
    path.lineTo(0.0, size.height);
    path.moveTo(midPoint.x, midPoint.y);
    path.quadraticBezierTo(midPoint.x + 75.0, midPoint.y, rightPoint.x, rightPoint.y);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
//    path.moveTo(rightPoint.x, rightPoint.y);
//    path.quadraticBezierTo(rightHandle.x, rightHandle.y, leftPoint.x, leftPoint.y);
//    path.lineTo(0.0, size.height);
//    path.lineTo(size.width, size.height);
//    path.close();

    canvas.drawPath(path, sliderPaint);

    canvas.drawCircle(new Offset(rightPoint.x, rightPoint.y), 10.0, debugPaint);
//    canvas.drawCircle(new Offset(rightHandle.x, rightHandle.y), 5.0, debugPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}