// quanghuuxx (quanghuuxx@gmail.com)
// ------
// Copyright 2024 quanghuuxx, Ltd. All rights reserved.

import 'package:image/image.dart' as img;

import 'package:drawthing/potrace_d/potrace.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

class DetectScreen extends StatefulWidget {
  const DetectScreen({super.key});

  static final regContentSvgPath = RegExp(r'(M|m)\d([\s\S]*)\d+\w');

  @override
  State<DetectScreen> createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen> {
  bool _loaded = false;

  late List<Path?> _paths;

  @override
  void initState() {
    super.initState();

    Future.wait<Path?>([
      'assets/mask_000.png',
      'assets/mask_001.png',
      'assets/mask_002.png',
      'assets/mask_003.png',
    ].map((e) async {
      final s = await rootBundle.load(e);
      final svg = await compute(_genSvgFromImage, s.buffer.asUint8List());
      final m = DetectScreen.regContentSvgPath.stringMatch(svg);

      if (m != null) {
        return parseSvgPath(m);
      }
      return null;
    })).then((value) {
      if (!mounted) return;
      setState(() {
        _loaded = true;
        _paths = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (_, constraints) {
        if (!_loaded) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        final fitted = applyBoxFit(BoxFit.contain, const Size(600, 400), constraints.biggest);

        return Center(
          child: CustomPaint(
            foregroundPainter: _Painter(
              paths: _paths,
              scaleFactory: fitted.destination.width / fitted.source.width,
            ),
            size: fitted.destination,
            child: Image.asset(
              'assets/detect_origin.jpg',
              fit: BoxFit.contain,
            ),
          ),
        );
      }),
    );
  }
}

class _Painter extends CustomPainter {
  final List<Path?> paths;
  final double scaleFactory;

  _Painter({
    required this.paths,
    required this.scaleFactory,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final m = Matrix4.identity()..scale(scaleFactory);

    canvas.saveLayer(null, Paint());

    for (var element in paths) {
      if (element != null) {
        canvas.drawPath(
          element.transform(m.storage),
          Paint()
            ..color = const Color(0x78DA4141)
            ..blendMode = BlendMode.src,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

String _genSvgFromImage(Uint8List uint8list) {
  final image = img.decodePng(uint8list, frame: 0);
  return potrace(image!);
}
