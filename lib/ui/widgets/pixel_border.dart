import 'package:flutter/material.dart';

///
/// A ShapeBorder to draw a box with pixelated corners.
/// (The border itself is not actually painted)
///
class PixelBorder extends ShapeBorder {
  /// The radii for each corner.
  final double borderRadius;

  /// granularity of the pixels. the smaller,
  /// the less pixel-y the border will look
  final double granularity;

  const PixelBorder({
    @required this.borderRadius,
    @required this.granularity,
  })  : assert(granularity > 0),
        assert(borderRadius > granularity);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    final path = Path();

    path.addRect(Rect.fromLTWH(
      borderRadius,
      0,
      rect.width - 2 * borderRadius,
      rect.height,
    ));

    for (double i = 0; i < borderRadius; i += granularity) {
      final top = borderRadius - i;
      final height = rect.height - 2 * (borderRadius - i);

      path
        // left side
        ..addRect(Rect.fromLTWH(i, top, granularity, height))
        // right side
        ..addRect(
          Rect.fromLTWH(rect.width - i - granularity, top, granularity, height),
        );
    }

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    // do nothing
  }

  @override
  ShapeBorder scale(double t) => PixelBorder(
        borderRadius: borderRadius * t,
        granularity: granularity * t,
      );
}
