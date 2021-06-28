import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:animated_text_kit/animated_text_kit.dart';

bool change = true;

void main() => runApp(My());

class My extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CountDownTimer(),
    );
  }
}

class CountDownTimer extends StatefulWidget {
  @override
  _CountDownTimerState createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  late AnimationController controller;

  String get timerString {
    Duration duration = controller.duration! * controller.value;
    return '${(duration.inSeconds % 60).toString().padLeft(1, '0')}';
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    controller.reverse(from: controller.value == 0.0 ? 1.0 : controller.value);
  }

  Widget build(BuildContext context) {
    //ThemeData themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.amberAccent.withOpacity(1),
      body: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: FractionalOffset.center,
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Stack(
                          children: <Widget>[
                            Positioned.fill(
                              child: AnimatedBuilder(
                                animation: controller,
                                builder: (context, child) {
                                  return CustomPaint(
                                      painter: CustomTimerPainter(
                                        animation: controller,
                                        backgroundColor: Colors.white,
                                        color: Colors.amber,
                                      ));
                                },
                              ),
                            ),
                            Align(
                              alignment: FractionalOffset.center,
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  AnimatedBuilder(
                                      animation: controller,
                                      builder: (context, child) {
                                        return Center(
                                          child: SizedBox(
                                            width: 250.0,
                                            child: Center(
                                              child: DefaultTextStyle(
                                                style: const TextStyle(
                                                  fontSize: 112.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                child: AnimatedTextKit(
                                                  animatedTexts: [
                                                    FadeAnimatedText('3',
                                                        duration: Duration(
                                                            milliseconds: 500)),
                                                    FadeAnimatedText('2',
                                                        duration: Duration(
                                                            milliseconds: 500)),
                                                    FadeAnimatedText('1',
                                                        duration: Duration(
                                                            milliseconds: 500)),
                                                  ],
                                                  isRepeatingAnimation: false,
                                                  onFinished: () {
                                                    Navigator.of(context,
                                                        rootNavigator: true)
                                                        .pop();
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
