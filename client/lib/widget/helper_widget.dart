import 'package:flutter/material.dart';

class HelperWidget {
  static BoxDecoration cardDecoration({
    double radius = 12,
    bool shapeCircle = false,
  }) {
    return BoxDecoration(
      color: Colors.white,
      shape: shapeCircle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: shapeCircle ? null : BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
