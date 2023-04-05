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

import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.HorizontalScrollView;
import android.widget.ScrollView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.platform.PlatformView;

/** A simple PlatformView that wraps a View and sets its reference to null on dispose(). */
class FlutterPlatformView implements PlatformView {

  @Nullable private View view;

  FlutterPlatformView(@NonNull View view) {
    this.view = view;
  }

  @Override
  public View getView() {
    return view;
  }

  @Override
  public void dispose() {
    this.view = null;
  }
}

interface AdViewSizeChangeListener {
  void onSizeChanged(int width, int height);
}

class AutoSizingPlatformViewContainer extends HorizontalScrollView {

  private final AdViewSizeChangeListener listener;
  private Integer width;
  private Integer height;

  public AutoSizingPlatformViewContainer(
    Context context,
    View childView,
    AdViewSizeChangeListener listener) {
    super(context);
    this.listener = listener;
    ScrollView scrollView = new ScrollView(context);
    scrollView.setClipChildren(false);
    scrollView.setVerticalScrollBarEnabled(false);
    scrollView.setHorizontalScrollBarEnabled(false);
    scrollView.addView(childView);
    addView(scrollView);
    childView.addOnLayoutChangeListener(
            new View.OnLayoutChangeListener() {
              @Override
              public void onLayoutChange(
                      View v,
                      int left,
                      int top,
                      int right,
                      int bottom,
                      int oldLeft,
                      int oldTop,
                      int oldRight,
                      int oldBottom) {
                // Forward the new height to its container.
                int newHeight = v.getMeasuredHeight();
                int newWidth = v.getMeasuredWidth();
                if (width == null || height == null || newHeight != height || newWidth != width) {
                  listener.onSizeChanged(newWidth, newHeight);
                }
                width = newWidth;
                height = newHeight;
              }
            });
  }
}

class AutoSizingPlatformView implements PlatformView {

  /** The underlying ad view. */
  private FlutterAdWithPlatformView flutterAdWithPlatformView;
  private View containerView;

  private AdInstanceManager manager;
  @Nullable
  private Integer width;
  @Nullable
  private Integer height;

  AutoSizingPlatformView(
          FlutterAdWithPlatformView flutterAdWithPlatformView,
          AdInstanceManager manager) {
    this.flutterAdWithPlatformView = flutterAdWithPlatformView;
    this.manager = manager;
    View view = flutterAdWithPlatformView.getView();
    int adId = flutterAdWithPlatformView.adId;
    if (view == null) {
      return;
    }

    Activity activity = manager.getActivity();
    if (activity == null) {
      // TODO - log warning
      return;
    }

    // This is a wierd hack that uses a nested scroll view inside a horizontal scroll view, to allow
    // the ad view to size to its intrinsic content size.
    // Flutter automatically sets the frame of the top level platform view to match the initial
    // size given by Flutter. If the ad view is the top level platform view then it does not
    // go to its natural content size, even if we set its LayoutParams to wrap_content.
    HorizontalScrollView horizontalScrollView = new HorizontalScrollView(activity);

    ScrollView scrollView = new ScrollView(activity);
    scrollView.setClipChildren(false);
    scrollView.setVerticalScrollBarEnabled(false);
    scrollView.setHorizontalScrollBarEnabled(false);
    scrollView.addView(view);
    // TODO - do not create a new view each time
    // TODO - check what's going on if the ad refreshes to a different ad size.
    view.addOnLayoutChangeListener(
      new View.OnLayoutChangeListener() {
        @Override
        public void onLayoutChange(
                View v,
                int left,
                int top,
                int right,
                int bottom,
                int oldLeft,
                int oldTop,
                int oldRight,
                int oldBottom) {
          // Forward the new height to its container.
          int newHeight = v.getMeasuredHeight();
          int newWidth = v.getMeasuredWidth();
          if (width == null || height == null || newHeight != height || newWidth != width) {
            manager.onPlatformViewSizeChanged(adId, newWidth, newHeight);
          }
          width = newWidth;
          height = newHeight;
        }
      });
    horizontalScrollView.addView(scrollView);
    this.containerView = horizontalScrollView;
  }

  @Override
  public View getView() {
    return containerView;
  }

  @Override
  public void dispose() {
    this.flutterAdWithPlatformView = null;
    this.manager = null;
  }
}