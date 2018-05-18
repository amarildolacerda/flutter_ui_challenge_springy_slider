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
  final paddingTop = 50.0;
  final paddingBottom = 50.0;

  double sliderPercent = 0.5;
  double startDragY;
  double startDragPercent;

  void onDragStart(DragStartDetails details) {
    startDragY = details.globalPosition.dy;
    startDragPercent = sliderPercent;
  }

  void onDragUpdate(DragUpdateDetails details) {
    final dragDistance = startDragY - details.globalPosition.dy;
    final sliderHeight = context.size.height;
    final dragPercent = dragDistance / sliderHeight;

    setState(() {
      sliderPercent = startDragPercent + dragPercent;
    });
  }

  void onDragEnd(DragEndDetails details) {
    setState(() {
      startDragY = null;
      startDragPercent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        // Colorful marks on a white background.
        new SliderMarks(
          markCount: widget.markCount,
          color: widget.positiveColor,
          paddingTop: paddingTop,
          paddingBottom: paddingBottom,
        ),
        // Light marks on a colorful background, clipped based on the
        // slider position and user interaction.
        new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return new ClipPath(
              clipper: new SliderClipper(
                sliderPercent: sliderPercent,
                paddingTop: paddingTop,
                paddingBottom: paddingBottom,
              ),
              child: new Stack(
                children: <Widget>[
                  new Container(
                    color: widget.positiveColor,
                  ),
                  new SliderMarks(
                    markCount: widget.markCount,
                    color: widget.negativeColor,
                    paddingTop: paddingTop,
                    paddingBottom: paddingBottom,
                  ),
                ],
              ),
            );
          },
        ),
        // Positive and negative points displays above and below the current
        // slider position.
        new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final height = constraints.maxHeight - paddingTop - paddingBottom;
            print('Max height: ${height}');
            final sliderY = height * (1.0 - sliderPercent) + paddingTop;
            print('slider y: $sliderY');
            final pointsYouNeed = (100 * (1.0 - sliderPercent)).round();
            final pointsYouHave = (100 * sliderPercent).round();

            return new Stack(
              children: <Widget>[
                new Positioned(
                  left: 30.0,
                  top: sliderY - 50.0,
                  child: new FractionalTranslation(
                    translation: const Offset(0.0, -1.0),
                    child: new Points(
                      points: pointsYouNeed,
                      isAboveSlider: true,
                      isPointsYouNeed: true,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                new Positioned(
                  left: 30.0,
                  top: sliderY + 50.0,
                  child: new Points(
                    points: pointsYouHave,
                    isAboveSlider: false,
                    isPointsYouNeed: false,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ],
            );
          },
        ),
        // Drag detector
        new GestureDetector(
          onPanStart: onDragStart,
          onPanUpdate: onDragUpdate,
          onPanEnd: onDragEnd,
          child: new Container(
            color: Colors.transparent,
          ),
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
  final double sliderPercent;
  final double paddingTop;
  final double paddingBottom;

  SliderClipper({
    this.sliderPercent = 0.0,
    this.paddingTop = 0.0,
    this.paddingBottom = 0.0,
  });

  @override
  Path getClip(Size size) {
    Path compositePath = new Path();

    final top = paddingTop;
    final bottom = size.height;
    final height = (bottom - paddingBottom) - top;
    final percentFromBottom = 1.0 - sliderPercent;

    compositePath.addRect(
      new Rect.fromLTRB(
        0.0,
        top + (percentFromBottom * height),
        size.width,
        bottom,
      ),
    );

    return compositePath;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class Points extends StatelessWidget {
  final int points;
  final bool isAboveSlider;
  final bool isPointsYouNeed;
  final Color color;

  Points({
    this.points,
    this.isAboveSlider = true,
    this.isPointsYouNeed = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = points / 100.0;
    final pointTextSize = 30.0 + (70.0 * percent);

    return new Row(
      crossAxisAlignment: isAboveSlider ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        new FractionalTranslation(
          translation: new Offset(0.0, isAboveSlider ? 0.18 : -0.18),
          child: new Text(
            '$points',
            style: new TextStyle(
              fontSize: pointTextSize,
              color: color,
            ),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: new Text(
                  'POINTS',
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              new Text(
                isPointsYouNeed ? 'YOU NEED' : 'YOU HAVE',
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
