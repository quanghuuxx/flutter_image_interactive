// quanghuuxx (quanghuuxx@gmail.com)
// ------
// Copyright 2023 quanghuuxx, Ltd. All rights reserved.

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

class PaintViewModel {
  final ui.Image source, response;

  PaintViewModel({
    required this.response,
    required this.source,
  });

  late ui.ImageShader sourceShader, responseShader;

  late ui.Size destinationSize, sourceSize;

  late double x, y;

  late BoxConstraints constraints;

  late Rect boundary = Rect.zero;

  void applyConstraints(BoxConstraints constraints) {
    final FittedSizes fittedSizes = applyBoxFit(
      BoxFit.contain,
      source.size,
      (this.constraints = constraints).biggest,
    );

    sourceSize = fittedSizes.destination;

    if (boundary != Rect.zero && boundary.size != source.size) {
      return applyCrop(boundary);
    }

    final m = Matrix4.identity()
      ..scale(
        x = fittedSizes.destination.width / fittedSizes.source.width,
        y = fittedSizes.destination.height / fittedSizes.source.height,
      );

    sourceShader = ImageShader(
      source,
      TileMode.decal,
      TileMode.decal,
      m.storage,
    );

    responseShader = ImageShader(
      response,
      TileMode.decal,
      TileMode.decal,
      m.storage,
    );

    destinationSize = fittedSizes.destination;
    boundary = Offset.zero & source.size;
  }

  void applyCrop(Rect crop) {
    final FittedSizes fittedSizes = applyBoxFit(
      BoxFit.contain,
      (boundary = crop).size,
      constraints.biggest,
    );

    final m = Matrix4.identity()
      ..scale(
        x = fittedSizes.destination.width / fittedSizes.source.width,
        y = fittedSizes.destination.height / fittedSizes.source.height,
      )
      ..translate(
        -crop.topLeft.dx,
        -crop.topLeft.dy,
      );

    sourceShader.dispose();
    sourceShader = ImageShader(
      source,
      TileMode.decal,
      TileMode.decal,
      m.storage,
    );

    responseShader.dispose();
    responseShader = ImageShader(
      response,
      TileMode.decal,
      TileMode.decal,
      m.storage,
    );

    destinationSize = fittedSizes.destination;
  }
}

extension UIImageExt on ui.Image {
  ui.Size get size {
    return ui.Size(width.toDouble(), height.toDouble());
  }
}

extension RectExt on Rect {
  Rect scale(double x, [double? y]) {
    return Rect.fromLTWH(
      left * x,
      top * (y ?? x),
      width * x,
      height * (y ?? x),
    );
  }
}
