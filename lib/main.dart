// quanghuuxx (quanghuuxx@gmail.com)
// ------
// Copyright 2023 quanghuuxx, Ltd. All rights reserved.

import 'dart:developer';

import 'package:drawthing/croping.dart';
import 'package:drawthing/detect/detect_screen.dart';
import 'package:drawthing/drawing_board.dart';
import 'package:drawthing/model/paint_viewmodel.dart';
import 'package:drawthing/model/sketch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(
    home: MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final ValueNotifier<List<Sketch>> _painter = ValueNotifier([]);

  Sketch? sketch;
  PaintViewModel? viewModel;
  bool _onStart = false;

  @override
  void initState() {
    super.initState();

    Future.sync(() async {
      final s = await rootBundle.load('assets/rm_bgr_origin.png');
      final r = await rootBundle.load('assets/rm_bgr_response.png');

      final source = await decodeImageFromList(s.buffer.asUint8List());
      final response = await decodeImageFromList(r.buffer.asUint8List());

      viewModel = PaintViewModel(response: response, source: source);

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DetectScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.data_object),
            ),
            IconButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const Croping(),
                  ),
                );

                if (result is Rect) {
                  setState(() {
                    viewModel!.applyCrop(result);
                  });
                }
              },
              icon: const Icon(Icons.crop),
            ),
            IconButton(
              onPressed: () {
                _painter.value = List.empty();
              },
              icon: const Icon(Icons.remove_circle_rounded),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: (viewModel != null)
                    ? LayoutBuilder(builder: (_, constraints) {
                        return Listener(
                          onPointerDown: (event) {
                            sketch = Sketch(
                              points: {event.localPosition},
                              color: Colors.black,
                              strokeWidth: 16,
                              tag: viewModel!.boundary,
                            );

                            _onStart = true;
                          },
                          onPointerMove: (event) {
                            sketch = sketch!.change(
                              points: Set.from(sketch!.points)..add(event.localPosition),
                            );

                            if (_onStart) {
                              _painter.value = List.from(_painter.value)..add(sketch!);
                              _onStart = false;
                            }

                            _painter.value = List.from(_painter.value)..last = sketch!;
                          },
                          onPointerUp: (event) {
                            log(sketch.toString());
                            sketch = null;
                          },
                          child: ClipRect(
                            child: DrawingBoard(
                              constraints: constraints,
                              viewModel: viewModel!,
                              painter: _painter,
                            ),
                          ),
                        );
                      })
                    : const CircularProgressIndicator.adaptive(),
              ),
            ),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent),
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: const Text("Bottom Bar"),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _painter.dispose();
    super.dispose();
  }
}
