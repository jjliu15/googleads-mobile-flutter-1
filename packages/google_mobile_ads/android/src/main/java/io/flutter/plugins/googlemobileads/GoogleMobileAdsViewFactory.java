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
import android.graphics.Color;
import android.view.View;
import android.widget.TextView;
import androidx.annotation.NonNull;
import io.flutter.BuildConfig;
import io.flutter.Log;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/** Displays loaded FlutterAds for an AdInstanceManager */
final class GoogleMobileAdsViewFactory extends PlatformViewFactory {
  @NonNull private final AdInstanceManager manager;
  private final Map<Integer, View> platformViewMap = new ConcurrentHashMap<>();

  private static class ErrorTextView implements PlatformView {
    private final TextView textView;

    private ErrorTextView(Context context, String message) {
      textView = new TextView(context);
      textView.setText(message);
      textView.setBackgroundColor(Color.RED);
      textView.setTextColor(Color.YELLOW);
    }

    @Override
    public View getView() {
      return textView;
    }

    @Override
    public void dispose() {}
  }

  public GoogleMobileAdsViewFactory(@NonNull AdInstanceManager manager) {
    super(StandardMessageCodec.INSTANCE);
    this.manager = manager;
  }

  @Override
  @SuppressWarnings("unchecked")
  public PlatformView create(Context context, int viewId, Object args) {
    //
    if (args instanceof Integer) {
      Integer adId = (Integer) args;
      assert adId != null;
      View platformView = platformViewMap.get(adId);
      if (platformView != null) {
        return new FlutterPlatformView(platformView);
      }
      FlutterAdWithPlatformView ad = (FlutterAdWithPlatformView) manager.adForId(adId);
      if (ad == null || ad.getView() == null) {
        return getErrorView(context, adId);
      }
      platformViewMap.put(adId, ad.getView());
      return new FlutterPlatformView(ad.getView());
    } else if (args instanceof Map) {
      // TODO(jjliu15): Make other ad widgets pass their args as a map
      Map<String, Object> map = (Map<String, Object>) args;
      Integer adId = (Integer) map.get("adId");
      assert adId != null;
      View platformView = platformViewMap.get(adId);
      if (platformView != null) {
        return new FlutterPlatformView(platformView);
      }
      FlutterAdWithPlatformView flutterAdWithPlatformView =
        (FlutterAdWithPlatformView) manager.adForId(adId);
      assert flutterAdWithPlatformView != null;
      platformView = new AutoSizingPlatformViewContainer(manager.getActivity(), flutterAdWithPlatformView.getView(), new AdViewSizeChangeListener() {
        @Override
        public void onSizeChanged(int width, int height) {
          manager.onPlatformViewSizeChanged(adId, width, height);
        }
      });
      platformViewMap.put(adId, platformView);
      return new FlutterPlatformView(platformView);
    }
    return getErrorView(context, viewId);
  }

  /**
   * Returns an ErrorView with a debug message for debug builds only. Otherwise just returns an
   * empty PlatformView.
   */
  private static PlatformView getErrorView(@NonNull final Context context, int adId) {
    final String message =
        String.format(
            Locale.getDefault(),
            "This ad may have not been loaded or has been disposed. "
                + "Ad with the following id could not be found: %d.",
            adId);

    if (BuildConfig.DEBUG) {
      return new ErrorTextView(context, message);
    } else {
      Log.e(GoogleMobileAdsViewFactory.class.getSimpleName(), message);
      return new PlatformView() {
        @Override
        public View getView() {
          return new View(context);
        }

        @Override
        public void dispose() {
          // Do nothing.
        }
      };
    }
  }
}
