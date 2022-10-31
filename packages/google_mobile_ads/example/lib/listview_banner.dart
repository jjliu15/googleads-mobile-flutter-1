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

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'constants.dart';

/// This example demonstrates banner ads at the bottom of a list view.
class ListViewBannerExample extends StatefulWidget {
  @override
  _ListViewBannerExampleState createState() => _ListViewBannerExampleState();
}

class _ListViewBannerExampleState extends State<ListViewBannerExample> {
  final ScrollController _scrollController = ScrollController();
  final _textFieldController = TextEditingController();
  AdManagerBannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Banner'),
    ),
    body: Center(
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          TextField(
            controller: _textFieldController,
            obscureText: false,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Ad Unit Id',
              suffixIcon: IconButton(
                key: ValueKey('clearAdUnitButton'),
                onPressed: _textFieldController.clear,
                icon: Icon(Icons.clear),
              ),
            ),
            key: ValueKey('adUnitTextField'),
          ),
          ElevatedButton(
            onPressed: () => _loadAd(adUnitId()),
            key: ValueKey('loadAdButton'),
            child: Text('Load Banner Ad'),
          ),
          ElevatedButton(
            onPressed: () => _scrollToBottom(),
            key: ValueKey('scrollToBottomButton'),
            child: Text('Scroll to bottom'),
          ),
          Container(
            width: 200,
            height: 500,
          ),
          _bannerWidget(),
        ],
      ),
    ),
  );

  Widget _bannerWidget() {
    final banner = _bannerAd;
    if (banner == null || !_isLoaded) {
      return Container();
    }
    return Container(
      width: banner.sizes.first.width.toDouble(),
      height: banner.sizes.first.height.toDouble(),
      key: ValueKey('bannerContainer'),
      child: AdWidget(ad: banner),
    );
  }

  String adUnitId() {
    if (_textFieldController.text.isNotEmpty) {
      return _textFieldController.text;
    }
    return '/6499/example/banner';
  }

  void _loadAd(String adUnitId) {
    print('Loading ad with ad unit: $adUnitId');
    final adRequest = AdManagerAdRequest(
      keywords: <String>[],
      contentUrl: 'http://test-content-url.com',
      nonPersonalizedAds: true,
    );

    _bannerAd = AdManagerBannerAd(
      adUnitId: adUnitId,
      request: adRequest,
      sizes: [AdSize.banner],
      listener: AdManagerBannerAdListener(
        onAdLoaded: (ad) {
          print('GMA Flutter Test App - Banner loaded');
          print('ResponseInfo: ${ad.responseInfo}');
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (_, error) {
          print('GMA Flutter Test App - Banner failedToLoad: $error');
        },
        onAdOpened: (_) {
          print('GMA Flutter Test App - Banner onAdOpened.');
        },
        onAdClosed: (_) {
          print('GMA Flutter Test App - Banner onAdClosed.');
        },
        onAdWillDismissScreen: (_) {
          print('GMA Flutter Test App - Banner onAdWillDismissScreen.');
        },
        onAdImpression: (_) {
          print('GMA Flutter Test App - Banner onAdImpression.');
        },
        onPaidEvent: (_, valueMicros, precision, currencyCode) {
          print(
            'GMA Flutter Test App - Banner onPaidEvent value: $valueMicros,'
                ' precision: $precision, currencyCode: $currencyCode',
          );
        },
        onAdClicked: (_) {
          print('GMA Flutter Test App - Banner onAdClicked.');
        },
      ),
    )..load();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }
}
