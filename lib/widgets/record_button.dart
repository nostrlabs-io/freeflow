import 'dart:math';

import 'package:flutter/widgets.dart';

class RecordButton extends StatelessWidget {
  final double size;
  final double progress_bar_size;
  final double progress;

  RecordButton({this.size = 80, this.progress = 0, this.progress_bar_size = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: progress > 0
            ? Color.fromARGB(100, 200, 200, 200)
            : Color.fromARGB(100, 255, 255, 255),
        borderRadius: BorderRadius.circular(size),
      ),
      child: CustomPaint(
        size: Size.square(size),
        painter: ArcPainter(
            progress, progress_bar_size, Color.fromARGB(200, 230, 0, 0)),
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  final double progress;
  final double width;
  final Color color;

  ArcPainter(this.progress, this.width, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
        center: size.center(Offset.zero),
        width: size.width + width * 2,
        height: size.height + width * 2);

    canvas.drawArc(
        rect,
        0,
        2 * pi,
        false,
        Paint()
          ..strokeWidth = width
          ..color = Color.fromARGB(100, 50, 50, 50)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
    if (progress > 0) {
      canvas.drawArc(
          rect,
          -pi / 2,
          progress.clamp(0, 1) * 2 * pi,
          false,
          Paint()
            ..strokeWidth = width
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ArcPainter) {
      return oldDelegate.progress != this.progress;
    }
    return false;
  }
}
