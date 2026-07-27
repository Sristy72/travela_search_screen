// shimmer_placeholders.dart  ← FINAL WORKING VERSION
import 'package:flutter/material.dart';

class ShimmerPlaceholders {
  static Widget rectangle({
    double width = double.infinity,
    double height = double.infinity,
    double borderRadius = 0,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // ← THIS IS THE KEY
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  static Widget circle({double diameter = 48}) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // ← Also change this
        shape: BoxShape.circle,
      ),
    );
  }

  static Widget textLine({
    double width = double.infinity,
    double height = 12,
    double borderRadius = 4,
  }) {
    return rectangle(width: width, height: height, borderRadius: borderRadius);
  }
}