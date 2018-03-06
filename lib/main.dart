import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

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

class _SpringySliderState extends State<SpringySlider> with TickerProviderStateMixin {

  double sliderPercent;
  double sliderPercentOnStartDrag;
  Offset touchStart;
  Offset touchPoint;

  AnimationController springAnimationController;
  ScrollSpringSimulation springSimulation;

  @override
  void initState() {
    sliderPercent = widget.sliderPercent;

    springSimulation = new ScrollSpringSimulation(
        new SpringDescription(
          mass: 1.0,
          stiffness: 1.0,
          damping: 1.0,
        ),
        0.0,
        1.0,
        0.0,
    );

    springAnimationController = new AnimationController(vsync: this)
    ..addListener(() {
      print('Spring: ${springSimulation.x(springAnimationController.value)}');
    });

//    for (var i = 0; i < 100; ++i) {
//      print('Spring value: ${springSimulation.x(i.toDouble())}');
//    }
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
//    springAnimationController.animateWith(springSimulation);

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
    final midPointY = ((sliderValueY - prevSliderValueY) * 1.2 + prevSliderValueY).clamp(0.0, size.height);

    Point leftPoint, midPoint, rightPoint;

    leftPoint = new Point(-100.0, prevSliderValueY);
    rightPoint = new Point(size.width + 50.0, prevSliderValueY);

    if (null != touchPoint) {
      midPoint = new Point(touchPoint.dx, midPointY);
    } else {
      midPoint = new Point(size.width / 2, midPointY);
    }

    final path = new Path();
    path.moveTo(midPoint.x, midPoint.y);
    path.quadraticBezierTo(midPoint.x - 100.0, midPoint.y, leftPoint.x, leftPoint.y);
    path.lineTo(0.0, size.height);
    path.moveTo(midPoint.x, midPoint.y);
    path.quadraticBezierTo(midPoint.x + 100.0, midPoint.y, rightPoint.x, rightPoint.y);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();

    canvas.drawPath(path, sliderPaint);

    canvas.drawCircle(new Offset(rightPoint.x, rightPoint.y), 10.0, debugPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}