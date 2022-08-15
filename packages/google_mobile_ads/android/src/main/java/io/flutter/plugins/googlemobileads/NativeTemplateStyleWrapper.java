package io.flutter.plugins.googlemobileads;

import androidx.annotation.Nullable;
import com.google.android.ads.nativetemplates.NativeTemplateStyle;

public class NativeTemplateStyleWrapper {

  NativeTemplateStyleWrapper(
    int size,
    @Nullable TextStyleWrapper callToActionTextStyle,
    @Nullable ColorWrapper callToActionBackgroundColor) {
    this.size = size;
    this.callToActionTextStyle = callToActionTextStyle;
    this.callToActionBackgroundColor = callToActionBackgroundColor;
  }

  private final int size;
  @Nullable private final TextStyleWrapper callToActionTextStyle;
  @Nullable private final ColorWrapper callToActionBackgroundColor;

  NativeTemplateStyle asNativeTemplateStyle() {
    NativeTemplateStyle.Builder builder = new NativeTemplateStyle.Builder();
    if (callToActionBackgroundColor != null) {
      builder.withCallToActionBackgroundColor(callToActionBackgroundColor.asColorDrawable());
    }
    if (callToActionTextStyle != null) {
      builder.withCallToActionTextSize(callToActionTextStyle.getFontSize());
      builder.withCallToActionTypefaceColor(callToActionTextStyle.getTypeFaceColor());
      builder.withCallToActionTextTypeface()
    }
    return builder.build();
  }
}
