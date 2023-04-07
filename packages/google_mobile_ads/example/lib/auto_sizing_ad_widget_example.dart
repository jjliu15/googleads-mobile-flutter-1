// Copyright 2022 Google LLC
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

// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'constants.dart';

/// This example demonstrates native templates.
class AutoSizingAdWidgetExample extends StatefulWidget {
  @override
  _AutoSizingAdWidgetExampleState createState() =>
      _AutoSizingAdWidgetExampleState();
}

class _AutoSizingAdWidgetExampleState extends State<AutoSizingAdWidgetExample> {
  BannerAd? _bannerAd;
  bool _bannerIsLoaded = false;
  NativeAd? _nativeAd;
  bool _nativeIsLoaded = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('Auto sizing ad widget example'),
      ),
      body: Center(
        child: Column(
          children: [Container(), Container()
            // _bannerIsLoaded
            //     ? Container(width: 500, height: 200, child: AdWidget(ad: _bannerAd!))
            //     : Container(),
          ],
        ),
        // child: Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //   child: ListView.separated(
        //     itemCount: 10,
        //     separatorBuilder: (BuildContext context, int index) {
        //       return Container(
        //         height: 40,
        //       );
        //     },
        //     itemBuilder: (BuildContext context, int index) {
        //       if (index == 3 && _nativeAd != null && _nativeIsLoaded) {
        //         return Align(
        //           alignment: Alignment.center,
        //           child: AutoSizingAdWidget(ad: _nativeAd!),
        //         );
        //       }
        //
        //       if (index == 5 && _bannerAd != null && _bannerIsLoaded) {
        //         return Container(width: 500, height: 200, child: AdWidget(ad: _bannerAd!));
        //         // return Align(
        //         //     alignment: Alignment.center,
        //         //     child: AutoSizingAdWidget(ad: _bannerAd!),
        //         // );
        //       }
        //       return Text(
        //         Constants.placeholderText,
        //         style: TextStyle(fontSize: 24),
        //       );
        //     },
        //   ),
        // ),
      ),
    bottomNavigationBar: SafeArea(
      left: true,
      right: true,
      bottom: true,
      child: _bannerIsLoaded
          ? Container(alignment: Alignment.center, width: 468, height: 60, child: SizedBox(child: AdWidget(ad: _bannerAd!)))
          : Container(),
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Create the ad objects and load ads.
    _bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/6300978111'
            : 'ca-app-pub-3940256099942544/2934735716',
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('$BannerAd loaded.');
            setState(() {
              _bannerIsLoaded = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('$BannerAd failedToLoad: $error');
            ad.dispose();
          },
          onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
          onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
        ),
        request: AdRequest())
      ..load();

    _nativeAd = NativeAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/2247696110'
          : 'ca-app-pub-3940256099942544/3986624511',
      request: AdRequest(),
      factoryId: 'adFactoryExample',
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print('$NativeAd loaded.');
          setState(() {
            _nativeIsLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$NativeAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$NativeAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$NativeAd onAdClosed.'),
      ),
    )..load();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
  }
}
