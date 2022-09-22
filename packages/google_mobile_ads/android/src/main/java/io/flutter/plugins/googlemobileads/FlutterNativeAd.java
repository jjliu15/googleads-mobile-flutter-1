// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package io.flutter.plugins.googlemobileads;

import android.content.Context;
import android.graphics.Typeface;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.ads.nativetemplates.NativeTemplateStyle;
import com.google.android.ads.nativetemplates.TemplateView;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.admanager.AdManagerAdRequest;
import com.google.android.gms.ads.nativead.NativeAd;
import com.google.android.gms.ads.nativead.NativeAd.OnNativeAdLoadedListener;
import com.google.android.gms.ads.nativead.NativeAdOptions;
import com.google.android.gms.ads.nativead.NativeAdView;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory;
import java.util.Map;

/** A wrapper for {@link NativeAd}. */
class FlutterNativeAd extends FlutterAd {
  private static final String TAG = "FlutterNativeAd";

  @NonNull private final AdInstanceManager manager;
  @NonNull private final String adUnitId;
  @NonNull private final NativeAdFactory adFactory;
  @NonNull private final FlutterAdLoader flutterAdLoader;
  @Nullable private FlutterAdRequest request;
  @Nullable private FlutterAdManagerAdRequest adManagerRequest;
  @Nullable private Map<String, Object> customOptions;
  @Nullable private NativeAdView nativeAdView;
  @Nullable private TemplateView templateView;
  @Nullable private final FlutterNativeAdOptions nativeAdOptions;
  @Nullable private final NativeTemplateStyleWrapper nativeTemplateStyle;

  static class Builder {
    @Nullable private AdInstanceManager manager;
    @Nullable private String adUnitId;
    @Nullable private NativeAdFactory adFactory;
    @Nullable private FlutterAdRequest request;
    @Nullable private FlutterAdManagerAdRequest adManagerRequest;
    @Nullable private Map<String, Object> customOptions;
    @Nullable private Integer id;
    @Nullable private FlutterNativeAdOptions nativeAdOptions;
    @Nullable private FlutterAdLoader flutterAdLoader;
    @Nullable private NativeTemplateStyleWrapper nativeTemplateStyle;

    public Builder setAdFactory(@NonNull NativeAdFactory adFactory) {
      this.adFactory = adFactory;
      return this;
    }

    public Builder setId(int id) {
      this.id = id;
      return this;
    }

    public Builder setCustomOptions(@Nullable Map<String, Object> customOptions) {
      this.customOptions = customOptions;
      return this;
    }

    public Builder setManager(@NonNull AdInstanceManager manager) {
      this.manager = manager;
      return this;
    }

    public Builder setAdUnitId(@NonNull String adUnitId) {
      this.adUnitId = adUnitId;
      return this;
    }

    public Builder setRequest(@NonNull FlutterAdRequest request) {
      this.request = request;
      return this;
    }

    public Builder setAdManagerRequest(@NonNull FlutterAdManagerAdRequest request) {
      this.adManagerRequest = request;
      return this;
    }

    public Builder setNativeAdOptions(@Nullable FlutterNativeAdOptions nativeAdOptions) {
      this.nativeAdOptions = nativeAdOptions;
      return this;
    }

    public Builder setNativeTemplateStyle(@Nullable NativeTemplateStyleWrapper nativeTemplateStyle) {
      this.nativeTemplateStyle = nativeTemplateStyle;
      return this;
    }

    public Builder setFlutterAdLoader(@NonNull FlutterAdLoader flutterAdLoader) {
      this.flutterAdLoader = flutterAdLoader;
      return this;
    }

    FlutterNativeAd build() {
      if (manager == null) {
        throw new IllegalStateException("AdInstanceManager cannot not be null.");
      } else if (adUnitId == null) {
        throw new IllegalStateException("AdUnitId cannot not be null.");
      } else if (adFactory == null) {
        throw new IllegalStateException("NativeAdFactory cannot not be null.");
      } else if (request == null && adManagerRequest == null) {
        throw new IllegalStateException("adRequest or addManagerRequest must be non-null.");
      }

      final FlutterNativeAd nativeAd;
      if (request == null) {
        nativeAd =
            new FlutterNativeAd(
                id,
                manager,
                adUnitId,
                adFactory,
                adManagerRequest,
                flutterAdLoader,
                customOptions,
                nativeAdOptions,
                nativeTemplateStyle);
      } else {
        nativeAd =
            new FlutterNativeAd(
                id,
                manager,
                adUnitId,
                adFactory,
                request,
                flutterAdLoader,
                customOptions,
                nativeAdOptions,
                nativeTemplateStyle);
      }
      return nativeAd;
    }
  }

  protected FlutterNativeAd(
      int adId,
      @NonNull AdInstanceManager manager,
      @NonNull String adUnitId,
      @NonNull NativeAdFactory adFactory,
      @NonNull FlutterAdRequest request,
      @NonNull FlutterAdLoader flutterAdLoader,
      @Nullable Map<String, Object> customOptions,
      @Nullable FlutterNativeAdOptions nativeAdOptions,
      @Nullable NativeTemplateStyleWrapper nativeTemplateStyle) {
    super(adId);
    this.manager = manager;
    this.adUnitId = adUnitId;
    this.adFactory = adFactory;
    this.request = request;
    this.flutterAdLoader = flutterAdLoader;
    this.customOptions = customOptions;
    this.nativeAdOptions = nativeAdOptions;
    this.nativeTemplateStyle = nativeTemplateStyle;
  }

  protected FlutterNativeAd(
      int adId,
      @NonNull AdInstanceManager manager,
      @NonNull String adUnitId,
      @NonNull NativeAdFactory adFactory,
      @NonNull FlutterAdManagerAdRequest adManagerRequest,
      @NonNull FlutterAdLoader flutterAdLoader,
      @Nullable Map<String, Object> customOptions,
      @Nullable FlutterNativeAdOptions nativeAdOptions,
      @Nullable NativeTemplateStyleWrapper nativeTemplateStyle) {
    super(adId);
    this.manager = manager;
    this.adUnitId = adUnitId;
    this.adFactory = adFactory;
    this.adManagerRequest = adManagerRequest;
    this.flutterAdLoader = flutterAdLoader;
    this.customOptions = customOptions;
    this.nativeAdOptions = nativeAdOptions;
    this.nativeTemplateStyle = nativeTemplateStyle;
  }

  @Override
  void load() {
    final OnNativeAdLoadedListener loadedListener = new FlutterNativeAdLoadedListener(this);
    final AdListener adListener = new FlutterNativeAdListener(adId, manager);
    // Note we delegate loading the ad to FlutterAdLoader mainly for testing purposes.
    // As of 20.0.0 of GMA, mockito is unable to mock AdLoader.
    final NativeAdOptions options =
        this.nativeAdOptions == null
            ? new NativeAdOptions.Builder().build()
            : nativeAdOptions.asNativeAdOptions();
    if (request != null) {
      flutterAdLoader.loadNativeAd(
          adUnitId, loadedListener, options, adListener, request.asAdRequest(adUnitId));
    } else if (adManagerRequest != null) {
      AdManagerAdRequest adManagerAdRequest = adManagerRequest.asAdManagerAdRequest(adUnitId);
      flutterAdLoader.loadAdManagerNativeAd(
          adUnitId, loadedListener, options, adListener, adManagerAdRequest);
    } else {
      Log.e(TAG, "A null or invalid ad request was provided.");
    }
  }

  @Override
  @Nullable
  public PlatformView getPlatformView() {
    if (nativeAdView != null) {
      return new FlutterPlatformView(nativeAdView);
    } else if (templateView != null) {
      return new FlutterPlatformView(templateView);
    }
    return null;
  }

  void onNativeAdLoaded(@NonNull NativeAd nativeAd) {
    if (nativeTemplateStyle == null) {
      nativeAdView = adFactory.createNativeAd(nativeAd, customOptions);
    } else {
      LayoutInflater layoutInflater = (LayoutInflater) flutterAdLoader.getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
      TemplateView templateView = (TemplateView) layoutInflater.inflate(R.layout.template_small, null);
      Typeface.MONOSPACE;
      NativeTemplateStyle style = new NativeTemplateStyle.Builder()
          .withCallToActionTextTypeface()
          .build();
      templateView.setStyles(style);
      templateView.setNativeAd(nativeAd);
      this.templateView = templateView;
    }
    nativeAd.setOnPaidEventListener(new FlutterPaidEventListener(manager, this));
    manager.onAdLoaded(adId, nativeAd.getResponseInfo());
  }

  @Override
  void dispose() {
    if (nativeAdView != null) {
      nativeAdView.destroy();
      nativeAdView = null;
    }
    if (templateView != null) {
      templateView.destroyNativeAd();
      templateView = null;
    }
  }
}
