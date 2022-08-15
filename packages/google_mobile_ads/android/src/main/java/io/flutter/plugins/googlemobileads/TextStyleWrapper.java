package io.flutter.plugins.googlemobileads;

import android.graphics.Typeface;

public class TextStyleWrapper {

  // TODO - handle nullables
  TextStyleWrapper(
      String fontFamily,
      ColorWrapper color,
      double fontSize) {
    this.fontFamily = fontFamily;
    this.color = color;
    this.fontSize = fontSize;
  }

  private final String fontFamily;
  private final ColorWrapper color;
  private final double fontSize;

  public float getFontSize() {
    return (float) fontSize;
  }

  public int getTypeFaceColor() {
    return color.getRgba();
  }

  public Typeface getTypeFace() {
    return Typeface.create(fontFamily, Typeface.NORMAL);
  }
}
