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
  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new CustomPaint(
        painter: new SpringySliderPainter(
          color: ACCENT_COLOR,
        ),
        child: new Container(),
      )
    );
  }
}

class SpringySliderPainter extends CustomPainter {

  final Color color;
  final Paint sliderPaint;

  SpringySliderPainter({
    this.color = Colors.black,
  }) : sliderPaint = new Paint() {
    sliderPaint.color = this.color;
    sliderPaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(new Rect.fromLTWH(0.0, size.height / 2, size.width, size.height / 2), sliderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}