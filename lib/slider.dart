import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:meta/meta.dart';

const ACCENT_COLOR = const Color(0xFFFF6688);

class SpringySlider extends StatefulWidget {
  final tickCount;
  final sliderPercent;

  SpringySlider({
    this.tickCount = 14,
    this.sliderPercent = 0.5,
  });

  @override
  _SpringySliderState createState() => new _SpringySliderState();
}

class _SpringySliderState extends State<SpringySlider> with TickerProviderStateMixin {
  final int markCount = 12;

  SpringSliderController springSliderController;
  double sliderPercent;
  double sliderPercentUnconstrained;
  double sliderPercentOnStartDrag;
  Offset touchStart;
  Offset touchPoint;
  double activePoints;
  double wavePosition;

  AnimationController springAnimationController;
  ScrollSpringSimulation springSimulation;

  @override
  void initState() {
    super.initState();

    sliderPercent = widget.sliderPercent;
    sliderPercentUnconstrained = sliderPercent;
    activePoints = sliderPercent * 100.0;
    wavePosition = sliderPercent;
    springSliderController = new SpringSliderController(
      sliderValue: widget.sliderPercent,
      vsync: this,
    )..addListener(() => setState(() {
          if (springSliderController.state == SpringSliderState.dragging) {
            activePoints = springSliderController.dragSliderValue * 100.0;
            wavePosition = springSliderController.dragSliderValue;
          } else {
            activePoints = (springSliderController.sliderValue ?? 0.0) * 100.0;
            wavePosition = springSliderController.springValue ?? 0.0;
          }
        }));
  }

  @override
  void dispose() {
    springSliderController.dispose();
    super.dispose();
  }

  _onStartDrag(DragStartDetails details) {
    touchStart = (context.findRenderObject() as RenderBox).globalToLocal(details.globalPosition);
    touchPoint = touchStart;

    sliderPercentOnStartDrag = sliderPercent;

    springSliderController.onDragStart();
  }

  _onDrag(DragUpdateDetails details) {
    setState(() {
      touchPoint = (context.findRenderObject() as RenderBox).globalToLocal(details.globalPosition);

      final dragVector = touchStart.dy - touchPoint.dy;
      final normalizedDragVector = (dragVector / context.size.height).clamp(-1.0, 1.0);
      sliderPercentUnconstrained = sliderPercentOnStartDrag + normalizedDragVector;
      sliderPercent = sliderPercentUnconstrained.clamp(0.0, 1.0);

      springSliderController.dragValue = sliderPercent;
      springSliderController.dragValueUnconstrained = sliderPercentUnconstrained;
      print('Spring value constrained: $sliderPercent, unconstraiend: $sliderPercentUnconstrained');
    });
  }

  _onDragEnd(DragEndDetails details) {
    setState(() {
      touchStart = null;
      touchPoint = null;
      sliderPercentOnStartDrag = null;

      springSliderController.sliderValue = sliderPercent;
      springSliderController.sliderValueUnconstrained = sliderPercentUnconstrained;
      springSliderController.onDragRelease();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new SliderScale(
          markCount: markCount,
          backgroundColor: Colors.white,
          foregroundColor: ACCENT_COLOR,
        ),
        new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final spacesCount = markCount + 1; // +1 to get space at very top and bottom
            final gap = constraints.maxHeight / spacesCount;

            return new ClipPath(
              clipper: new SpringySliderClipper(
                controller: springSliderController,
                color: ACCENT_COLOR,
                topPadding: gap,
                bottomPadding: gap,
                sliderPercent: sliderPercent,
                prevSliderPercent: sliderPercentOnStartDrag ?? sliderPercent,
                touchPoint: touchPoint,
              ),
              child: new SliderScale(
                markCount: markCount,
                backgroundColor: ACCENT_COLOR,
                foregroundColor: Colors.white,
              ),
            );
          },
        ),
//        new SpringySlider(
//          sliderPercent: 0.5,
//        ),
        new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final spacesCount = markCount + 1; // +1 to get space at very top and bottom
            final gap = constraints.maxHeight / spacesCount;
            final baseY = (1.0 - wavePosition) * (constraints.maxHeight - 2 * gap) + gap;

            return new Stack(
              children: <Widget>[
                new Positioned(
                  left: 0.0,
                  top: baseY - (40.0 * (1.0 - wavePosition) + 10.0),
                  child: new FractionalTranslation(
                    translation: const Offset(0.0, -1.0),
                    child: new PointCount(
                      alignTop: false,
                      points: 100 - activePoints.round(),
                      description: 'POINTS\nYOU NEED',
                      color: ACCENT_COLOR,
                    ),
                  ),
                ),
                new Positioned(
                  left: 0.0,
                  top: baseY + (40.0 * (wavePosition) + 10.0),
                  child: new PointCount(
                    alignTop: true,
                    points: activePoints.round(),
                    description: 'POINTS\nYOU HAVE',
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
        new GestureDetector(
          onPanStart: _onStartDrag,
          onPanUpdate: _onDrag,
          onPanEnd: _onDragEnd,
          child: new Container(
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }
}

class PointCount extends StatelessWidget {
  final bool alignTop;
  final int points;
  final String description;
  final Color color;

  PointCount({
    this.alignTop = false,
    this.points,
    this.description = "",
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    double percent = points / 100.0;

    return new Padding(
      padding: const EdgeInsets.only(left: 50.0),
      child: new Row(
        crossAxisAlignment: alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: <Widget>[
          new FractionalTranslation(
            translation: new Offset(-0.05, alignTop ? -0.18 : 0.18),
            child: new Text(
              '$points',
              style: new TextStyle(
                color: color,
                fontSize: 30.0 + (90.0 * percent),
              ),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: new Text(
              description,
              style: new TextStyle(
                color: color,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SliderScale extends StatelessWidget {
  final int markCount;
  final Color backgroundColor;
  final Color foregroundColor;

  SliderScale({
    this.markCount,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: backgroundColor,
      child: new CustomPaint(
        painter: new SliderScalePainter(
          color: foregroundColor,
          markCount: markCount,
        ),
      ),
    );
  }
}

class SliderScalePainter extends CustomPainter {
  final Color color;
  final int markCount;
  final Paint markPaint;

  SliderScalePainter({
    this.color,
    this.markCount,
  }) : markPaint = new Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final spacesCount = markCount + 1; // +1 to get space at very top and bottom
    final gap = size.height / spacesCount;
    final rightPadding = 25.0;

    double markY = gap;
    double markWidth;
    for (int i = 0; i < markCount; ++i) {
      if (i == 0 || i == (markCount - 1)) {
        markWidth = 40.0;
      } else if (i == 1 || i == (markCount - 2)) {
        markWidth = 25.0;
      } else {
        markWidth = 15.0;
      }

      canvas.drawLine(
        new Offset(size.width - markWidth - rightPadding, markY),
        new Offset(size.width - rightPadding, markY),
        markPaint,
      );

      markY += gap;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class SpringySliderClipper extends CustomClipper<Path> {
  final SpringSliderController controller;
  final double sliderPercent; // [0.0, 1.0]
  final double prevSliderPercent; // [0.0, 1.0]
  final Color color;
  final double topPadding;
  final double bottomPadding;
  final Offset touchPoint;
  final Paint sliderPaint;
  final Paint debugPaint;

  SpringySliderClipper({
    @required this.controller,
    this.sliderPercent = 0.0,
    this.prevSliderPercent = 0.0,
    this.color = Colors.black,
    this.topPadding = 0.0,
    this.bottomPadding = 0.0,
    this.touchPoint,
  })  : sliderPaint = new Paint(),
        debugPaint = new Paint() {
    sliderPaint.color = this.color;
    sliderPaint.style = PaintingStyle.fill;
    sliderPaint.strokeWidth = 2.0;

    debugPaint.color = Colors.black;
    debugPaint.style = PaintingStyle.fill;
  }

  @override
  Path getClip(Size size) {
    if (controller.state == SpringSliderState.dragging) {
      return _pathForTouching(size);
    } else if (controller.state == SpringSliderState.springing) {
      return _paintForSpringing(size);
    } else {
      return _paintForIdle(size);
    }
  }

  Path _pathForTouching(Size size) {
    Path compositePath = new Path();

    final topYCap = topPadding;
    final bottomYCap = size.height - bottomPadding;
    final paintHeight = bottomYCap - topYCap;

//    print('Slider Percent: ${controller.dragValue}, Prev Percent: ${controller.sliderValue}');
    final sliderValueY = bottomYCap - (paintHeight * controller.dragValue);
    final sliderValueYUnconstrained =
        bottomYCap - (paintHeight * controller.dragValueUnconstrained);
    final prevSliderValueY = bottomYCap - (paintHeight * controller.sliderValue);
    final crestYUnconstrained =
        ((sliderValueYUnconstrained - prevSliderValueY) * 1.2 + prevSliderValueY);
    final crestY = crestYUnconstrained.clamp(topYCap, bottomYCap);
    double excessMagnitude = 0.0;
    if (crestYUnconstrained < topYCap) {
      excessMagnitude = (crestYUnconstrained - topYCap).abs();
      print('Below zero. Excess: $excessMagnitude');
    } else if (crestYUnconstrained > bottomYCap) {
      excessMagnitude = crestYUnconstrained - bottomYCap;
      print('Beyond height. Excess: $excessMagnitude');
    }

    Point leftPoint, crestPoint, rightPoint;

    final touchOffset = touchPoint.dx - (size.width / 2);
    final left = -(size.width * 0.15);
    final crestX = (size.width / 2) + touchOffset;
    final right = size.width * 1.15;

    final baseControlPointWidth = 150.0;
    final thickeningFactor =
        pow(excessMagnitude, 2) / paintHeight; // If user drags beyond top/bottom boundary
    final controlPointWidth = (200.0 * thickeningFactor).abs() + baseControlPointWidth;
    print(
        'Control point width: $controlPointWidth, slider diff: ${sliderValueY - prevSliderValueY}, excess: $excessMagnitude}');

    rightPoint = new Point(right, prevSliderValueY);
    crestPoint = new Point(crestX, crestY);
    leftPoint = new Point(left, prevSliderValueY);

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

    if (sliderValueY > prevSliderValueY) {
      // We want to remove the right path.
      compositePath.fillType = PathFillType.evenOdd;
    }
    compositePath.addPath(pathRight, const Offset(0.0, 0.0));

    return compositePath;

//    sliderPaint.blendMode = sliderValueY > prevSliderValueY ? BlendMode.dstOut : BlendMode.src;
//    canvas.drawPath(pathRight, sliderPaint);
  }

  Path _paintForSpringing(Size size) {
    final topYCap = topPadding;
    final bottomYCap = size.height - bottomPadding;
    final paintHeight = bottomYCap - topYCap;

    Path compositePath = new Path();
//    print('Slider Percent: ${controller.dragValue}, Prev Percent: ${controller.sliderValue}');

    final touchOffset = null != touchPoint ? (touchPoint.dx - (size.width / 2)) : 0.0;

    final centerY = bottomYCap - (controller.springControlPointValue * paintHeight);
    final center = 0.0;
//    print("Center y: ${controller.springControlPointValue}");
    final centerPoint = new Point(center, centerY);

    final rightCrest = (size.width / 2) + touchOffset;
    final right = size.width;
    final rightCrestY = bottomYCap - (controller.springValue * paintHeight);
    final rightPoint = new Point(right, centerPoint.y);
    final rightCrestPoint = new Point(rightCrest, rightCrestY);
//    final rightCrestPoint = new Point(rightCrest, centerPoint.y);

    final leftCrestY = centerY - (rightCrestY - centerY);
//    final leftCrestY = ((sliderValueY - prevSliderValueY) * -1.2 + centerY);
    final left = -size.width;
    final leftCrest = -(size.width / 2) - touchOffset;
    final leftPoint = new Point(left, centerPoint.y);
    final leftCrestPoint = new Point(leftCrest, leftCrestY);
//    final leftCrestPoint = new Point(leftCrest, centerPoint.y);

    final xOffset = size.width * 0.15;
//    canvas.translate(xOffset, 0.0);

    // Fill bottom rectangle
    final path2 = new Path();
    path2.moveTo(leftPoint.x, leftPoint.y);
    path2.lineTo(centerPoint.x, centerPoint.y);
    path2.lineTo(rightPoint.x, rightPoint.y);
    path2.lineTo(size.width, size.height);
    path2.lineTo(leftPoint.x, size.height);
    path2.lineTo(leftPoint.x, leftPoint.y);
    path2.close();
//    sliderPaint.blendMode = debugPaint.blendMode;
//    canvas.drawPath(path2, sliderPaint);
    compositePath.addPath(path2, new Offset(xOffset, 0.0));

    // Move to left crest and curve to left of wave.
    final pathLeft = new Path();
    pathLeft.moveTo(leftCrestPoint.x, leftCrestPoint.y);
    pathLeft.quadraticBezierTo(
        leftCrestPoint.x - 100.0, leftCrestPoint.y, leftPoint.x, leftPoint.y);

    // Move to left crest and curve to center of wave.
    pathLeft.moveTo(leftCrestPoint.x, leftCrestPoint.y);
    pathLeft.quadraticBezierTo(
        leftCrestPoint.x + 100.0, leftCrestPoint.y, centerPoint.x, centerPoint.y);
    pathLeft.lineTo(leftPoint.x, leftPoint.y);
    pathLeft.close();

//    sliderPaint.blendMode = leftCrestPoint.y < centerY ? BlendMode.src : BlendMode.dstOut;
//    canvas.drawPath(pathLeft, sliderPaint);
    compositePath.addPath(pathLeft, new Offset(xOffset, 0.0));

    // Move to right crest and curve to center of wave.
    final pathRight = new Path();
    pathRight.moveTo(rightCrestPoint.x, rightCrestPoint.y);
    pathRight.quadraticBezierTo(
        rightCrestPoint.x - 100.0, rightCrestPoint.y, centerPoint.x, centerPoint.y);

    // Move to right crest and curve to right of wave.
    pathRight.moveTo(rightCrestPoint.x, rightCrestPoint.y);
    pathRight.quadraticBezierTo(
        rightCrestPoint.x + 100.0, rightCrestPoint.y, rightPoint.x, rightPoint.y);
    pathRight.lineTo(centerPoint.x, centerPoint.y);
    pathRight.close();

//    sliderPaint.blendMode = rightCrestPoint.y > centerY ? BlendMode.dstOut : BlendMode.src;
//    canvas.drawPath(pathRight, sliderPaint);
    compositePath.addPath(pathRight, new Offset(xOffset, 0.0));

    if (rightCrestPoint.y > centerY) {
      // We want to remove the right path.
      compositePath.fillType = PathFillType.evenOdd;
    }

    return compositePath;

    // Debug drawing
//    canvas.drawCircle(new Offset(centerPoint.x, centerPoint.y), 10.0, debugPaint);
//    canvas.drawCircle(new Offset(rightCrestPoint.x, rightCrestPoint.y), 10.0, debugPaint);
//    canvas.drawCircle(new Offset(rightPoint.x, rightPoint.y), 10.0, debugPaint);
  }

  Path _paintForIdle(Size size) {
    final topYCap = topPadding;
    final bottomYCap = size.height - bottomPadding;
    final paintHeight = bottomYCap - topYCap;

    final sliderValueY = bottomYCap - (controller.sliderValue * paintHeight);
    final leftPoint = new Point(0.0, sliderValueY);
    final rightPoint = new Point(size.width, sliderValueY);

    final path = new Path();
    path.moveTo(leftPoint.x, leftPoint.y);
    path.lineTo(rightPoint.x, rightPoint.y);
    path.lineTo(size.width, size.height);
    path.lineTo(leftPoint.x, size.height);
    path.lineTo(leftPoint.x, leftPoint.y);
    path.close();
//    sliderPaint.blendMode = debugPaint.blendMode;
//    canvas.drawPath(path, sliderPaint);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

//class SpringySliderPainter extends CustomPainter {
//  final SpringSliderController controller;
//  final double sliderPercent; // [0.0, 1.0]
//  final double prevSliderPercent; // [0.0, 1.0]
//  final Color color;
//  final Offset touchPoint;
//  final Paint sliderPaint;
//  final Paint debugPaint;
//
//  SpringySliderPainter({
//    @required this.controller,
//    this.sliderPercent = 0.0,
//    this.prevSliderPercent = 0.0,
//    this.color = Colors.black,
//    this.touchPoint,
//  })  : sliderPaint = new Paint(),
//        debugPaint = new Paint() {
//    sliderPaint.color = this.color;
//    sliderPaint.style = PaintingStyle.fill;
//    sliderPaint.strokeWidth = 2.0;
//
//    debugPaint.color = Colors.black;
//    debugPaint.style = PaintingStyle.fill;
//  }
//
//  @override
//  void paint(Canvas canvas, Size size) {
//    canvas.clipRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height));
//
//    if (controller.state == SpringSliderState.dragging) {
//      _paintForTouch(canvas, size);
//    } else if (controller.state == SpringSliderState.springing) {
//      _paintForSpringing(canvas, size);
//    } else {
//      _paintForIdle(canvas, size);
//    }
//  }
//
//  void _paintForTouch(Canvas canvas, Size size) {
////    print('Slider Percent: ${controller.dragValue}, Prev Percent: ${controller.sliderValue}');
//    final sliderValueY = size.height - (size.height * controller.dragValue);
//    final prevSliderValueY = size.height - (size.height * controller.sliderValue);
//    final crestY =
//        ((sliderValueY - prevSliderValueY) * 1.2 + prevSliderValueY).clamp(0.0, size.height);
//
//    Point leftPoint, crestPoint, rightPoint;
//
//    final touchOffset = touchPoint.dx - (size.width / 2);
//    final left = -(size.width * 0.15);
//    final crestX = (size.width / 2) + touchOffset;
//    final right = size.width * 1.15;
//    final controlPointWidth = 200.0 * (1.0 - ((sliderValueY - prevSliderValueY) / 750.0).abs());
//
//    rightPoint = new Point(right, prevSliderValueY);
//    crestPoint = new Point(crestX, crestY);
//    leftPoint = new Point(left, prevSliderValueY);
//
//    // Fill bottom rectangle
//    final path2 = new Path();
//    path2.moveTo(leftPoint.x, leftPoint.y);
//    path2.lineTo(rightPoint.x, rightPoint.y);
//    path2.lineTo(size.width, size.height);
//    path2.lineTo(leftPoint.x, size.height);
//    path2.lineTo(leftPoint.x, leftPoint.y);
//    path2.close();
//    sliderPaint.blendMode = debugPaint.blendMode;
//    canvas.drawPath(path2, sliderPaint);
//
//    // Move to right crest and curve to left of wave.
//    final pathRight = new Path();
//    pathRight.moveTo(crestPoint.x, crestPoint.y);
//    pathRight.quadraticBezierTo(
//        crestPoint.x - controlPointWidth, crestPoint.y, leftPoint.x, leftPoint.y);
//
//    // Move to right crest and curve to right of wave.
//    pathRight.moveTo(crestPoint.x, crestPoint.y);
//    pathRight.quadraticBezierTo(
//        crestPoint.x + controlPointWidth, crestPoint.y, rightPoint.x, rightPoint.y);
//    pathRight.lineTo(leftPoint.x, leftPoint.y);
//    pathRight.close();
//
//    sliderPaint.blendMode = sliderValueY > prevSliderValueY ? BlendMode.dstOut : BlendMode.src;
//    canvas.drawPath(pathRight, sliderPaint);
//
//    // Debug drawing
////    canvas.drawCircle(new Offset(crestPoint.x, crestPoint.y), 10.0, debugPaint);
////    canvas.drawCircle(new Offset(rightPoint.x, rightPoint.y), 10.0, debugPaint);
//  }
//
//  void _paintForSpringing(Canvas canvas, Size size) {
////    print('Slider Percent: ${controller.dragValue}, Prev Percent: ${controller.sliderValue}');
//
//    final touchOffset = null != touchPoint ? (touchPoint.dx - (size.width / 2)) : 0.0;
//
//    final centerY = size.height - (controller.springControlPointValue * size.height);
//    final center = 0.0;
////    print("Center y: ${controller.springControlPointValue}");
//    final centerPoint = new Point(center, centerY);
//
//    final rightCrest = (size.width / 2) + touchOffset;
//    final right = size.width;
//    final rightCrestY = size.height - (size.height * controller.springValue);
//    final rightPoint = new Point(right, centerPoint.y);
//    final rightCrestPoint = new Point(rightCrest, rightCrestY);
////    final rightCrestPoint = new Point(rightCrest, centerPoint.y);
//
//    final leftCrestY = centerY - (rightCrestY - centerY);
////    final leftCrestY = ((sliderValueY - prevSliderValueY) * -1.2 + centerY);
//    final left = -size.width;
//    final leftCrest = -(size.width / 2) - touchOffset;
//    final leftPoint = new Point(left, centerPoint.y);
//    final leftCrestPoint = new Point(leftCrest, leftCrestY);
////    final leftCrestPoint = new Point(leftCrest, centerPoint.y);
//
//    final xOffset = size.width * 0.15;
//    canvas.translate(xOffset, 0.0);
//
//    // Fill bottom rectangle
//    final path2 = new Path();
//    path2.moveTo(leftPoint.x, leftPoint.y);
//    path2.lineTo(centerPoint.x, centerPoint.y);
//    path2.lineTo(rightPoint.x, rightPoint.y);
//    path2.lineTo(size.width, size.height);
//    path2.lineTo(leftPoint.x, size.height);
//    path2.lineTo(leftPoint.x, leftPoint.y);
//    path2.close();
//    sliderPaint.blendMode = debugPaint.blendMode;
//    canvas.drawPath(path2, sliderPaint);
//
//    // Move to left crest and curve to left of wave.
//    final pathLeft = new Path();
//    pathLeft.moveTo(leftCrestPoint.x, leftCrestPoint.y);
//    pathLeft.quadraticBezierTo(
//        leftCrestPoint.x - 100.0, leftCrestPoint.y, leftPoint.x, leftPoint.y);
//
//    // Move to left crest and curve to center of wave.
//    pathLeft.moveTo(leftCrestPoint.x, leftCrestPoint.y);
//    pathLeft.quadraticBezierTo(
//        leftCrestPoint.x + 100.0, leftCrestPoint.y, centerPoint.x, centerPoint.y);
//    pathLeft.lineTo(leftPoint.x, leftPoint.y);
//    pathLeft.close();
//
//    sliderPaint.blendMode = leftCrestPoint.y < centerY ? BlendMode.src : BlendMode.dstOut;
//    canvas.drawPath(pathLeft, sliderPaint);
//
//    // Move to right crest and curve to center of wave.
//    final pathRight = new Path();
//    pathRight.moveTo(rightCrestPoint.x, rightCrestPoint.y);
//    pathRight.quadraticBezierTo(
//        rightCrestPoint.x - 100.0, rightCrestPoint.y, centerPoint.x, centerPoint.y);
//
//    // Move to right crest and curve to right of wave.
//    pathRight.moveTo(rightCrestPoint.x, rightCrestPoint.y);
//    pathRight.quadraticBezierTo(
//        rightCrestPoint.x + 100.0, rightCrestPoint.y, rightPoint.x, rightPoint.y);
//    pathRight.lineTo(centerPoint.x, centerPoint.y);
//    pathRight.close();
//
//    sliderPaint.blendMode = rightCrestPoint.y > centerY ? BlendMode.dstOut : BlendMode.src;
//    canvas.drawPath(pathRight, sliderPaint);
//
//    // Debug drawing
////    canvas.drawCircle(new Offset(centerPoint.x, centerPoint.y), 10.0, debugPaint);
////    canvas.drawCircle(new Offset(rightCrestPoint.x, rightCrestPoint.y), 10.0, debugPaint);
////    canvas.drawCircle(new Offset(rightPoint.x, rightPoint.y), 10.0, debugPaint);
//  }
//
//  void _paintForIdle(Canvas canvas, Size size) {
//    final sliderValueY = size.height - (size.height * controller.sliderValue);
//    final leftPoint = new Point(0.0, sliderValueY);
//    final rightPoint = new Point(size.width, sliderValueY);
//
//    final path = new Path();
//    path.moveTo(leftPoint.x, leftPoint.y);
//    path.lineTo(rightPoint.x, rightPoint.y);
//    path.lineTo(size.width, size.height);
//    path.lineTo(leftPoint.x, size.height);
//    path.lineTo(leftPoint.x, leftPoint.y);
//    path.close();
//    sliderPaint.blendMode = debugPaint.blendMode;
//    canvas.drawPath(path, sliderPaint);
//  }
//
//  @override
//  bool shouldRepaint(CustomPainter oldDelegate) {
//    return true;
//  }
//}

class SpringSliderController extends ChangeNotifier {
  SpringSliderState _state = SpringSliderState.idle;
  double _sliderValue; // Official, actionable slider value [0.0, 1.0]
  double _sliderValueUnconstrained;
  double _dragValue; // Current drag position as percent [0.0, 1.0], or null
  double _dragSliderValue;
  double _dragValueUnconstrained;
  double _springCrestValue; // Current spring position as percent [0.0, 1.0], or null
  double _springControlPointValue; // Current spring control point position [0.0, 1.0], or null

  final TickerProvider vsync;
  SpringSimulation crestSpring;
  SpringSimulation controlPointSpring;
  int springStartTime;
  int springTimeLastFrame;
  Timer springTimer;

  SpringSliderController({
    double sliderValue,
    this.vsync,
  }) : _sliderValue = sliderValue;

  SpringSliderState get state => _state;

  double get sliderValue => _sliderValue;

  set sliderValue(double newValue) {
    _sliderValue = newValue;
    notifyListeners();
  }

  double get sliderValueUnconstrained => _sliderValueUnconstrained;

  set sliderValueUnconstrained(double newValue) {
    _sliderValueUnconstrained = newValue;
    notifyListeners();
  }

  void onDragStart() {
    print('Dragging start');
    _cleanupSpring();

    _state = SpringSliderState.dragging;
    _dragValue = _sliderValue;
    _springControlPointValue = _sliderValue;

    notifyListeners();
  }

  double get dragValue => _dragValue;

  double get dragSliderValue => _dragSliderValue;

  set dragValue(double newValue) {
    _dragSliderValue = newValue;
    _dragValue = ((newValue - _sliderValue) * 1.2) + _sliderValue;
    notifyListeners();
  }

  double get dragValueUnconstrained => _dragValueUnconstrained;

  set dragValueUnconstrained(double newValue) {
    _dragValueUnconstrained = newValue;
    notifyListeners();
  }

  void onDragRelease() {
    if (_state != SpringSliderState.dragging) {
      return;
    }
    print('Dragging released. Springing.');
    print('Springing from $_dragValue to $_sliderValue.');
    print('Control point from $_springControlPointValue to $_sliderValue');

    controlPointSpring = new SpringSimulation(
      new SpringDescription(
        mass: 1.0,
        stiffness: 1000.0,
        damping: 50.0,
      ),
      _springControlPointValue,
      _sliderValue,
      0.0, // initial velocity
    );

    springStartTime = new DateTime.now().millisecondsSinceEpoch;
    springTimeLastFrame = springStartTime;
    _springTick();

    _state = SpringSliderState.springing;
    notifyListeners();
  }

  _springTick() {
//    print('Spring tick.');
    final now = new DateTime.now().millisecondsSinceEpoch;
    final timeDiff = (now - springStartTime) / 1000.0;
    final timeDiffSinceLastFrame = (now - springTimeLastFrame) / 1000.0;
    springTimeLastFrame = now;

    _springControlPointValue = controlPointSpring.x(timeDiff);

    final dragNormal = (_sliderValue - _dragValue) / (_sliderValue - _dragValue).abs();
    final prevSpringCrestValue = _springCrestValue ?? -1.0;
    _springCrestValue = crestSpring != null ? crestSpring.x(timeDiffSinceLastFrame) : _dragValue;
    final isDone = (prevSpringCrestValue - _springCrestValue).abs() < 0.000001;
//    print('Crest y: $_springCrestValue');
    crestSpring = new SpringSimulation(
      new SpringDescription(
        mass: 1.0,
        stiffness: 400.0,
        damping: 10.0,
      ),
      _springCrestValue,
      _springControlPointValue,
      crestSpring == null ? 0.5 * dragNormal : crestSpring.dx(timeDiffSinceLastFrame),
    );

    if (!crestSpring.isDone(timeDiff) || !isDone) {
      //!controlPointSpring.isDone(timeDiffSinceLastFrame)) {
      springTimer = new Timer(
        new Duration(milliseconds: 10),
        _springTick,
      );
    } else {
      print('Springing is done.');
      _state = SpringSliderState.idle;
      _cleanupSpring;
    }

    notifyListeners();
  }

  void _cleanupSpring() {
    if (springTimer != null) {
      springTimer.cancel();
    }
    crestSpring = null;
  }

  double get springValue => _springCrestValue;

  double get springControlPointValue => _springControlPointValue;
}

enum SpringSliderState {
  dragging,
  springing,
  idle,
}
