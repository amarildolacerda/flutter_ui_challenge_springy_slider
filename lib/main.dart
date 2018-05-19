import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';

void main() {
  timeDilation = 1.0;
  runApp(new MyApp());
}

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

class _SpringySliderState extends State<SpringySlider> with TickerProviderStateMixin {
  final paddingTop = 50.0;
  final paddingBottom = 50.0;

  SpringySliderController sliderController;

  @override
  void initState() {
    super.initState();

    sliderController = new SpringySliderController(vsync: this)
      ..sliderPercent = 0.5
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        // Colorful marks on a white background.
        new SliderMarks(
          markCount: widget.markCount,
          markColor: widget.positiveColor,
          backgroundColor: widget.negativeColor,
          paddingTop: paddingTop,
          paddingBottom: paddingBottom,
        ),
        // Light marks on a colorful background, clipped based on the
        // slider position and user interaction.
        new SliderFill(
          sliderController: sliderController,
          paddingTop: paddingTop,
          paddingBottom: paddingBottom,
          child: new SliderMarks(
            markCount: widget.markCount,
            markColor: widget.negativeColor,
            backgroundColor: widget.positiveColor,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
          ),
        ),
        // Positive and negative points displays above and below the current
        // slider position.
        new SlidingPoints(
          sliderController: sliderController,
          paddingTop: paddingTop,
          paddingBottom: paddingBottom,
        ),
        // Debug UI
//        new SliderDebug(
//          sliderController: sliderController,
//          paddingTop: paddingTop,
//          paddingBottom: paddingBottom,
//        ),
        // Drag detector
        new SliderDragger(
          sliderController: sliderController,
          paddingTop: paddingTop,
          paddingBottom: paddingBottom,
        ),
      ],
    );
  }
}

class SliderDragger extends StatefulWidget {
  final SpringySliderController sliderController;
  final double paddingTop;
  final double paddingBottom;

  SliderDragger({
    this.sliderController,
    this.paddingTop,
    this.paddingBottom,
  });

  @override
  _SliderDraggerState createState() => new _SliderDraggerState();
}

class _SliderDraggerState extends State<SliderDragger> {
  double startDragY;
  double startDragPercent;

  void onDragStart(DragStartDetails details) {
    startDragY = details.globalPosition.dy;
    startDragPercent = widget.sliderController.sliderPercent;

    final sliderWidth = context.size.width;
    final sliderLeftPosition =
        (context.findRenderObject() as RenderBox).localToGlobal(const Offset(0.0, 0.0)).dx;
    final dragHorizontalPercent = (details.globalPosition.dx - sliderLeftPosition) / sliderWidth;

    widget.sliderController.onDragStart(dragHorizontalPercent);
  }

  void onDragUpdate(DragUpdateDetails details) {
    final dragDistance = startDragY - details.globalPosition.dy;
    final sliderHeight = context.size.height - widget.paddingTop - widget.paddingBottom;
    final dragPercent = dragDistance / sliderHeight;

    final sliderWidth = context.size.width;
    final sliderLeftPosition =
        (context.findRenderObject() as RenderBox).localToGlobal(const Offset(0.0, 0.0)).dx;
    final dragHorizontalPercent = (details.globalPosition.dx - sliderLeftPosition) / sliderWidth;

    widget.sliderController.draggingPercents = new Offset(
      dragHorizontalPercent,
      startDragPercent + dragPercent,
    );
  }

  void onDragEnd(DragEndDetails details) {
    startDragY = null;
    startDragPercent = null;

    widget.sliderController.onDragEnd();
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onPanStart: onDragStart,
      onPanUpdate: onDragUpdate,
      onPanEnd: onDragEnd,
      child: new Container(
        color: Colors.transparent,
      ),
    );
  }
}

class SliderFill extends StatelessWidget {
  final SpringySliderController sliderController;
  final double paddingTop;
  final double paddingBottom;
  final Widget child;

  SliderFill({
    this.sliderController,
    this.paddingTop,
    this.paddingBottom,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return new ClipPath(
          clipper: new SliderClipper(
            sliderController: sliderController,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
          ),
          child: child,
        );
      },
    );
  }
}

class SliderDebug extends StatelessWidget {
  final SpringySliderController sliderController;
  final double paddingTop;
  final double paddingBottom;

  SliderDebug({
    this.sliderController,
    this.paddingTop,
    this.paddingBottom,
  });

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double sliderPercent = sliderController.sliderPercent;
        if (sliderController.state == SpringySliderState.dragging) {
          sliderPercent = sliderController.draggingPercent;
        }

        final height = constraints.maxHeight - paddingTop - paddingBottom;

        return new Stack(
          children: <Widget>[
            new Positioned(
              left: 0.0,
              right: 0.0,
              top: height * (1.0 - sliderPercent) + paddingTop,
              child: new Container(
                height: 2.0,
                color: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }
}

class SlidingPoints extends StatelessWidget {
  final SpringySliderController sliderController;
  final double paddingTop;
  final double paddingBottom;

  SlidingPoints({
    this.sliderController,
    this.paddingTop,
    this.paddingBottom,
  });

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double sliderPercent = sliderController.sliderPercent;
        if (sliderController.state == SpringySliderState.dragging) {
          sliderPercent = sliderController.draggingPercent.clamp(0.0, 1.0);
        }

        final height = constraints.maxHeight - paddingTop - paddingBottom;
        final sliderY = height * (1.0 - sliderPercent) + paddingTop;
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
    );
  }
}

class SliderMarks extends StatelessWidget {
  final int markCount;
  final Color markColor;
  final Color backgroundColor;
  final double paddingTop;
  final double paddingBottom;

  SliderMarks({
    this.markCount,
    this.markColor,
    this.backgroundColor,
    this.paddingTop,
    this.paddingBottom,
  });

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: new SliderMarksPainter(
        markCount: markCount,
        markColor: markColor,
        markThickness: 2.0,
        backgroundColor: backgroundColor,
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
  final Color markColor;
  final double markThickness;
  final Color backgroundColor;
  final double paddingTop;
  final double paddingBottom;
  final double paddingRight;
  final Paint markPaint;
  final Paint backgroundPaint;

  SliderMarksPainter({
    this.markCount,
    this.markColor,
    this.markThickness,
    this.backgroundColor,
    this.paddingTop = 0.0,
    this.paddingBottom = 0.0,
    this.paddingRight = 0.0,
  })  : markPaint = new Paint()
          ..color = markColor
          ..strokeWidth = markThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
        backgroundPaint = new Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      new Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      backgroundPaint,
    );

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
  final SpringySliderController sliderController;
  final double paddingTop;
  final double paddingBottom;

  SliderClipper({
    this.sliderController,
    this.paddingTop = 0.0,
    this.paddingBottom = 0.0,
  });

  @override
  Path getClip(Size size) {
    switch (sliderController.state) {
      case SpringySliderState.idle:
        return _clipIdle(size);
      case SpringySliderState.dragging:
        return _clipDragging(size);
      case SpringySliderState.springing:
        return _clipSpringing(size);
      default:
        throw new Exception('Invalid SpringySliderController state: ${sliderController.state}');
    }
  }

  Path _clipIdle(Size size) {
    Path compositePath = new Path();

    final top = paddingTop;
    final bottom = size.height;
    final height = (bottom - paddingBottom) - top;
    final percentFromBottom = 1.0 - sliderController.sliderPercent;

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

  Path _clipDragging(Size size) {
    Path compositePath = new Path();

    final top = paddingTop;
    final bottom = size.height - paddingBottom;
    final height = bottom - top;
    final basePercentFromBottom = 1.0 - sliderController.sliderPercent;
    final dragPercentDiff = sliderController.draggingPercent - sliderController.sliderPercent;
    final dragPercentFromBottom = 1.0 - (sliderController.sliderPercent + (dragPercentDiff * 1.2));

    final baseY = top + (basePercentFromBottom * height);
    final leftX = -0.15 * size.width;
    final leftPoint = new Point(leftX, baseY);
    final rightX = 0.15 * size.width + size.width;
    final rightPoint = new Point(rightX, baseY);

    final dragX = sliderController.draggingHorizontalPercent * size.width;
    final dragY = top + (dragPercentFromBottom * height);
    final crestPoint = new Point(dragX, dragY.clamp(top, bottom));

    // If user drags beyond top/bottom boundary
    double excessDrag = 0.0;
    if (sliderController.draggingPercent < 0.0) {
      excessDrag = sliderController.draggingPercent;
    } else if (sliderController.draggingPercent > 1.0) {
      excessDrag = sliderController.draggingPercent - 1.0;
    }
    final baseControlPointWidth = 150.0;
    final thickeningFactor = excessDrag * height * 0.05;
    final controlPointWidth = (200.0 * thickeningFactor).abs() + baseControlPointWidth;

    // Fill bottom rectangle
    final path2 = new Path();
    path2.moveTo(leftPoint.x, leftPoint.y);
    path2.lineTo(rightPoint.x, rightPoint.y);
    path2.lineTo(size.width, size.height);
    path2.lineTo(leftPoint.x, size.height);
    path2.lineTo(leftPoint.x, leftPoint.y);
    path2.close();
//    sliderPaint.blendMode = debugPaint.blendMode;
//    canvas.drawPath(path2, sliderPaint);
    compositePath.addPath(path2, const Offset(0.0, 0.0));

    // Move to right crest and curve to left of wave.
    final pathRight = new Path();
    pathRight.moveTo(crestPoint.x, crestPoint.y);
    pathRight.quadraticBezierTo(
        crestPoint.x - controlPointWidth, crestPoint.y, leftPoint.x, leftPoint.y);

    // Move to right crest and curve to right of wave.
    pathRight.moveTo(crestPoint.x, crestPoint.y);
    pathRight.quadraticBezierTo(
        crestPoint.x + controlPointWidth, crestPoint.y, rightPoint.x, rightPoint.y);
    pathRight.lineTo(leftPoint.x, leftPoint.y);
    pathRight.close();

    if (dragPercentFromBottom > basePercentFromBottom) {
      // We want to remove the right path.
      compositePath.fillType = PathFillType.evenOdd;
    }
    compositePath.addPath(pathRight, const Offset(0.0, 0.0));

    return compositePath;
  }

  Path _clipSpringing(Size size) {
    Path compositePath = new Path();

    final top = paddingTop;
    final bottom = size.height - paddingBottom;
    final height = bottom - top;
    final basePercentFromBottom = 1.0 - sliderController.sliderSpringingPercent;
    final crestSpringPercentFromBottom = 1.0 - sliderController.crestSpringingPercent;

    final baseY = top + (basePercentFromBottom * height);
    final leftX = -0.85 * size.width;
    final leftPoint = new Point(leftX, baseY);

    final centerX = 0.15 * size.width;
    final centerPoint = new Point(centerX, baseY);

    final rightX = 0.15 * size.width + size.width;
    final rightPoint = new Point(rightX, baseY);

    final crestY = top + (crestSpringPercentFromBottom * height);
    final crestPoint = new Point(((rightX - centerX) / 2) + centerX, crestY);

    final troughY = baseY + (baseY - crestY);
    final troughPoint = new Point((centerX - leftX) / 2 + leftX, troughY);

    print('Drawing spring blob. BaseY: $baseY, crestY: $crestY');

    final controlPointWidth = 100.0;

    // Fill bottom rectangle
    final path2 = new Path();
    path2.moveTo(leftPoint.x, leftPoint.y);
    path2.lineTo(rightPoint.x, rightPoint.y);
    path2.lineTo(size.width, size.height);
    path2.lineTo(leftPoint.x, size.height);
    path2.lineTo(leftPoint.x, leftPoint.y);
    path2.close();
    compositePath.addPath(path2, const Offset(0.0, 0.0));

    // Move to left crest/trough and curve to left of wave.
    final pathLeftCrestTrough = new Path();
    pathLeftCrestTrough.moveTo(troughPoint.x, troughPoint.y);
    pathLeftCrestTrough.quadraticBezierTo(
        troughPoint.x - controlPointWidth, troughPoint.y, leftPoint.x, leftPoint.y);

    // Move to left crest/trough and curve to center of wave.
    pathLeftCrestTrough.moveTo(troughPoint.x, troughPoint.y);
    pathLeftCrestTrough.quadraticBezierTo(
        troughPoint.x + controlPointWidth, troughPoint.y, centerPoint.x, centerPoint.y);
    pathLeftCrestTrough.lineTo(leftPoint.x, leftPoint.y);
    pathLeftCrestTrough.close();

    if (crestSpringPercentFromBottom < basePercentFromBottom) {
      // We want to remove the left path.
      compositePath.fillType = PathFillType.evenOdd;
    }
    compositePath.addPath(pathLeftCrestTrough, const Offset(0.0, 0.0));

    // Move to right crest and curve to center of wave.
    final pathRightCrestTrough = new Path();
    pathRightCrestTrough.moveTo(crestPoint.x, crestPoint.y);
    pathRightCrestTrough.quadraticBezierTo(
        crestPoint.x - controlPointWidth, crestPoint.y, centerPoint.x, centerPoint.y);

    // Move to right crest and curve to right of wave.
    pathRightCrestTrough.moveTo(crestPoint.x, crestPoint.y);
    pathRightCrestTrough.quadraticBezierTo(
        crestPoint.x + controlPointWidth, crestPoint.y, rightPoint.x, rightPoint.y);
    pathRightCrestTrough.lineTo(centerPoint.x, centerPoint.y);
    pathRightCrestTrough.close();

    if (crestSpringPercentFromBottom > basePercentFromBottom) {
      // We want to remove the right path.
      compositePath.fillType = PathFillType.evenOdd;
    }
    compositePath.addPath(pathRightCrestTrough, const Offset(0.0, 0.0));

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

class SpringySliderController extends ChangeNotifier {
  final SpringDescription sliderSpring = new SpringDescription(
    mass: 1.0,
    stiffness: 1000.0,
    damping: 30.0,
  );

  final SpringDescription crestSpring = new SpringDescription(
    mass: 1.0,
    stiffness: 5.0,
    damping: 0.5,
  );

  final TickerProvider _vsync;

  SpringySliderState _state = SpringySliderState.idle;

  // Stable slider value.
  double _sliderPercent;

  // Slider value during user drag.
  double _draggingPercent;
  // Horizontal drag position as a percent of the draggable area.
  double _draggingHorizontalPercent;

  // When springing to new slider value, this is where the UI is springing from.
  double _sliderSpringStartPercent;
  // When springing to new slider value, this is where the UI is springing to.
  double _sliderSpringEndPercent;
  // Current slider value during spring effect.
  double _sliderSpringingPercent;
  // Physics spring for the slider value.
  SpringSimulation _sliderSpringSimulation;
  double _crestSpringStartPercent;
  double _crestSpringEndPercent;
  double _crestSpringingPercent;
  // Physics spring for the drag crest/trough.
  SpringSimulation _crestSpringSimulation;
  // Ticker that computes current spring position based on time.
  Ticker _springTicker;
  // Elapsed time that has passed since the start of the spring.
  double _springTime;

  SpringySliderController({
    double sliderPercent = 0.0,
    vsync,
  })  : _vsync = vsync,
        _sliderPercent = sliderPercent;

  void dispose() {
    super.dispose();

    if (_springTicker != null) {
      _springTicker.dispose();
    }
  }

  SpringySliderState get state => _state;

  double get sliderPercent => _sliderPercent;

  set sliderPercent(double newValue) {
    _sliderPercent = newValue;
    notifyListeners();
  }

  double get draggingPercent => _draggingPercent;

  double get draggingHorizontalPercent => _draggingHorizontalPercent;

  set draggingPercents(Offset draggingPercents) {
    _draggingHorizontalPercent = draggingPercents.dx;
    _draggingPercent = draggingPercents.dy;
    notifyListeners();
  }

  void onDragStart(double dragHorizontalPercent) {
    print('onDragStart()');
    if (_springTicker != null) {
      _springTicker
        ..stop()
        ..dispose();
    }

    _state = SpringySliderState.dragging;
    _draggingPercent = _sliderPercent;
    _draggingHorizontalPercent = dragHorizontalPercent;

    notifyListeners();
  }

  void onDragEnd() {
    print('onDragEnd()');
    _state = SpringySliderState.springing;

    _sliderSpringingPercent = _sliderPercent;
    _sliderSpringStartPercent = _sliderPercent;
    _sliderSpringEndPercent = _draggingPercent.clamp(0.0, 1.0);

    _crestSpringingPercent = draggingPercent;
    _crestSpringStartPercent = draggingPercent;
    _crestSpringEndPercent = _sliderSpringStartPercent;

    _draggingPercent = null;

    // We update the _sliderPercent so clients don't need to wait
    // for springing to finish.
    _sliderPercent = _sliderSpringEndPercent;

    _startSpringing();

    notifyListeners();
  }

  void _startSpringing() {
    print('_startSpringing(), from: $_sliderSpringStartPercent, to: $_sliderSpringEndPercent');

    if (_sliderSpringStartPercent == _sliderSpringEndPercent) {
      _state = SpringySliderState.idle;
      notifyListeners();
      return;
    }

    _sliderSpringSimulation = new SpringSimulation(
      sliderSpring,
      _sliderSpringStartPercent,
      _sliderSpringEndPercent,
      0.0,
    );

    final crestSpringNormal = (_crestSpringEndPercent - _crestSpringStartPercent) /
        ((_crestSpringEndPercent - _crestSpringStartPercent)).abs();
    _crestSpringSimulation = new SpringSimulation(
      crestSpring,
      _crestSpringStartPercent,
      _crestSpringEndPercent,
      0.5 * crestSpringNormal,
    );

    _springTime = 0.0;

    _springTicker = _vsync.createTicker(_springTick)..start();

    notifyListeners();
  }

  void _springTick(Duration deltaTime) {
//    print('_sprintTick()');
    final _lastFrameTime = deltaTime.inMilliseconds.toDouble() / 1000.0;
    _springTime += _lastFrameTime;
//    print('spring time: $_springTime');

    _sliderSpringingPercent = _sliderSpringSimulation.x(_springTime);
//    print('spring percent: $_springingPercent');

    _crestSpringingPercent = _crestSpringSimulation.x(_lastFrameTime);
    _crestSpringSimulation = new SpringSimulation(
      crestSpring,
      _crestSpringingPercent,
      _sliderSpringingPercent,
      _crestSpringSimulation.dx(_lastFrameTime),
    );

    if (_sliderSpringSimulation.isDone(_springTime) &&
        _crestSpringSimulation.isDone(_lastFrameTime)) {
      print('spring is done.');
      _springTicker
        ..stop()
        ..dispose();
      _springTicker = null;

      _state = SpringySliderState.idle;
    }

    notifyListeners();
  }

  double get sliderSpringingPercent => _sliderSpringingPercent;

  double get crestSpringingPercent => _crestSpringingPercent;
}

enum SpringySliderState {
  idle,
  dragging,
  springing,
}
