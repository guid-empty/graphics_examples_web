import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as Vector;

void main() => runApp(MyApp());

class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) =>
      Path()..addOval(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2 + 100), radius: 80));

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Color(0xFF00A651)
      ..strokeWidth = 10;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 10,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      title: 'Flutter Demo',
      theme: ThemeData(
        backgroundColor: Colors.orange.shade100,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class WavePainter extends CustomPainter {
  AnimationController animationController;

  WavePainter({this.animationController});

  @override
  void paint(Canvas canvas, Size size) {
    List<Offset> polygonOffsets = [];
    for (int i = 0; i <= size.width.toInt(); i++) {
      polygonOffsets.add(Offset((animationController?.value ?? 0) * 200 + i.toDouble(),
          math.sin(3 * i % 360 * Vector.degrees2Radians) * 20 + size.height));
    }
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color(0xFF072946)
      ..strokeWidth = 10;

    canvas.drawPath(
        Path()
          ..addPolygon(polygonOffsets, false)
          ..lineTo(size.width, size.height + 200)
          ..lineTo(0.0, size.height + 200)
          ..close(),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: Colors.white,
      height: 800,
      width: 800,
      child: GestureDetector(
        onTap: () {
          if (animationController.isAnimating) {
            animationController.stop();
          } else {
            animationController.repeat();
          }
        },
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) => Stack(
            children: [
              Positioned(
                top: 50,
                left: 0,
                height: 800,
                width: size.width,
                child: Transform.rotate(
                  angle: math.pi * 2 * animationController.value,
                  child: Opacity(
                    child: Image.asset('assets/iphone.png'),
                    opacity: 1 - animationController.value,
                  ),
                ),
              ),
              Positioned(
                top: (size.height / 2 - 200),
                left: 0,
                height: 200,
                width: size.width,
                child: ClipPath(
                  clipper: CircleClipper(),
                  child: CustomPaint(
                    size: Size(200, 200),
                    painter: WavePainter(animationController: animationController),
                  ),
                ),
              ),
              Positioned(
                top: (size.height / 2 - 100),
                left: size.width / 2 - 100,
                child: CustomPaint(
                  size: Size(200, 200),
                  painter: CirclePainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 2), upperBound: 1);
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.decelerate,
    );

    //Future.delayed(Duration(seconds: 10), () => animationController.repeat());
  }
}
