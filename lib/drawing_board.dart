// quanghuuxx (quanghuuxx@gmail.com)
// ------
// Copyright 2023 quanghuuxx, Ltd. All rights reserved.

import 'dart:ui';

import 'package:drawthing/model/paint_viewmodel.dart';
import 'package:flutter/material.dart';

import 'model/sketch.dart';

class DrawingBoard extends StatefulWidget {
  const DrawingBoard({
    super.key,
    required this.constraints,
    required this.viewModel,
    required this.painter,
  });

  final BoxConstraints constraints;
  final PaintViewModel viewModel;
  final ValueNotifier<List<Sketch>> painter;

  @override
  State<DrawingBoard> createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  PaintViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();

    viewModel.applyConstraints(widget.constraints);
  }

  @override
  void didUpdateWidget(covariant DrawingBoard old) {
    super.didUpdateWidget(old);

    if (old.constraints != widget.constraints) {
      viewModel.applyConstraints(widget.constraints);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          painter: _BackgroundPainter(viewModel: viewModel),
          size: viewModel.destinationSize,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(),
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _Painter(
                painter: widget.painter,
                viewModel: widget.viewModel,
              ),
              size: viewModel.destinationSize,
            ),
          ),
        ),
      ],
    );
  }
}

class _Painter extends CustomPainter {
  _Painter({
    required this.painter,
    required this.viewModel,
  }) : super(repaint: painter);

  final ValueNotifier<List<Sketch>> painter;
  final PaintViewModel viewModel;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()..shader = viewModel.responseShader,
    );

    Paint paint = Paint()
      ..shader = viewModel.sourceShader
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final sketchs = painter.value;
    for (final sketch in sketchs) {
      paint
        ..color = sketch.color
        ..strokeWidth = sketch.strokeWidth;

      final count = sketch.points.length - 1;

      Path path = Path()..moveTo(sketch.points.elementAt(0).dx, sketch.points.elementAt(0).dy);
      if (sketch.points.length < 2) {
        // If the path only has one line, draw a dot.
        path.addOval(
          Rect.fromCircle(
            center: Offset(sketch.points.elementAt(0).dx, sketch.points.elementAt(0).dy),
            radius: 1,
          ),
        );
      } else {
        for (int i = 1; i < count; ++i) {
          final p0 = sketch.points.elementAt(i);
          final p1 = sketch.points.elementAt(i + 1);
          path.quadraticBezierTo(
            p0.dx,
            p0.dy,
            (p0.dx + p1.dx) / 2,
            (p0.dy + p1.dy) / 2,
          );
        }
      }

      Offset? shift;
      final tag = sketch.tag;
      final boundary = viewModel.boundary;
      if (tag is Rect && tag != boundary) {
        shift ??= -boundary.topLeft.scale(viewModel.x, viewModel.y);

        final rected = tag
            .scale(
              viewModel.x,
              viewModel.y,
            )
            .shift(shift);

        final fittedSizes = applyBoxFit(
          BoxFit.contain,
          tag.size,
          viewModel.constraints.biggest,
        );

        // canvas.drawRect(rected, Paint()..color = Colors.blue.withOpacity(.3));

        final m = Matrix4.identity()
          ..translate(
            rected.topLeft.dx,
            rected.topLeft.dy,
            0.0,
          )
          ..scale(
            rected.width / fittedSizes.destination.width,
            rected.height / fittedSizes.destination.height,
            1.0,
          );

        paint.strokeWidth = sketch.strokeWidth * (rected.width / fittedSizes.destination.width);

        path = path.transform(m.storage);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) => false;
}

class _BackgroundPainter extends CustomPainter {
  final PaintViewModel viewModel;

  _BackgroundPainter({
    required this.viewModel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()..shader = viewModel.sourceShader,
    );

    canvas.drawRect(rect, Paint()..color = Colors.white70);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
