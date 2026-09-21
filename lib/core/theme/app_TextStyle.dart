import 'package:flutter/material.dart';

abstract final class TextStyles {
  const TextStyles._();

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}