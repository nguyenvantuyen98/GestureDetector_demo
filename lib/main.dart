import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'point.dart';

const period = Duration(milliseconds: 100);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return const MaterialApp(
      title: 'GestureDetector',
      home: GestureDetectorWidget(),
    );
  }
}

class GestureDetectorWidget extends StatefulWidget {
  const GestureDetectorWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GestureDetectorWidgetState();
}

class _GestureDetectorWidgetState extends State<GestureDetectorWidget> {
  List<Offset> staticData = [];
  List<Point> dynamicData = [];
  int count = 0;
  Point? point;
  late Timer timer;

  void startTimer(Offset offset) {
    point = Point(offset, 10);
    timer = Timer.periodic(
      period,
      (Timer timer) {
        point?.time++;
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (offset) {
        setState(() {
          staticData.add(Offset(offset.globalPosition.dx - 5, offset.globalPosition.dy - 5));
          count++;
        });
      },
      onPanUpdate: (offset) {
        setState(() {
          staticData.add(Offset(offset.globalPosition.dx - 5, offset.globalPosition.dy - 5));
          count++;
        });
      },
      onLongPressStart: (offset) {
        startTimer(offset.globalPosition);
      },
      onLongPressEnd: (offset) {
        if (point == null) return;
        setState(() {
          dynamicData.add(
            Point(
                Offset(
                  point!.offset.dx - point!.time / 2,
                  point!.offset.dy - point!.time / 2,
                ),
                point!.time),
          );
        });
        point = null;
        timer.cancel();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            CustomPaint(
              painter: MyCustomPainter(
                staticData: staticData,
                dynamicData: dynamicData,
              ),
            ),
            Center(
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  MyCustomPainter({
    required this.staticData,
    required this.dynamicData,
  });

  final List<Offset> staticData;
  final List<Point> dynamicData;

  @override
  void paint(Canvas canvas, Size size) {
    for (var offset in staticData) {
      canvas.drawCircle(offset, 10, Paint()..color = Colors.red);
    }
    for (var point in dynamicData) {
      canvas.drawCircle(point.offset, point.time, Paint()..color = Colors.blue);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
