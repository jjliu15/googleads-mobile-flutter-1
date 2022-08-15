package io.flutter.plugins.googlemobileads;

import android.graphics.drawable.ColorDrawable;

public class ColorWrapper {

  ColorWrapper(int rgba) {
    this.rgba = rgba;
  }

  private final int rgba;

  ColorDrawable asColorDrawable() {
    return new ColorDrawable(rgba);
  }

  int getRgba() {
    return rgba;
  }
}
