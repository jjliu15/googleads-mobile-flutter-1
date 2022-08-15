
import 'package:flutter/material.dart';

/// The size of the template.
enum TemplateSize {
  small,
  medium,
}

/// Native template styles.
class NativeTemplateStyle {

  /// Initializer for [NativeTemplateStyle]
  NativeTemplateStyle({
    required this.templateSize,
    this.callToActionTextStyle,
    this.callToActionBackgroundColor,
  });

  /// The [TextStyle] for the call to action text.
  ///
  /// This only respects the size, color, and font family.
  /// Only the following font families are supported:
  /// Android: TODO
  /// iOS: TODO
  TextStyle? callToActionTextStyle;

  /// The background [Color] for call to action.
  Color? callToActionBackgroundColor;

  TemplateSize templateSize;
}