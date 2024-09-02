// ignore_for_file: public_member_api_docs, sort_constructors_first
// quanghuuxx (quanghuuxx@gmail.com)
// ------
// Copyright 2023 quanghuuxx, Ltd. All rights reserved.

import 'dart:ui';

import 'package:flutter/foundation.dart';

class Sketch {
  final Set<Offset> points;
  final Color color;
  final double strokeWidth;
  final Object? tag;

  Sketch({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.tag,
  });

  @override
  bool operator ==(covariant Sketch other) {
    if (identical(this, other)) return true;

    return setEquals(other.points, points) && other.color == color && other.strokeWidth == strokeWidth;
  }

  @override
  int get hashCode {
    return points.hashCode ^ color.hashCode ^ strokeWidth.hashCode & tag.hashCode;
  }

  Sketch change({
    Set<Offset>? points,
  }) {
    return Sketch(
      color: color,
      strokeWidth: strokeWidth,
      tag: tag,
      points: points ?? this.points,
    );
  }

  @override
  String toString() => 'Sketch(points: ${points.length} elements, color: $color, strokeWidth: $strokeWidth)';
}
