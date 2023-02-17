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

#import "FLTAdInstanceManager_Internal.h"

@implementation FLTAdInstanceManager {
  FLTGoogleMobileAdsCollection<NSNumber *, id<FLTAd>> *_ads;
  FlutterMethodChannel *_channel;
}

- (instancetype _Nonnull)initWithBinaryMessenger:
    (id<FlutterBinaryMessenger> _Nonnull)binaryMessenger {
  self = [super init];
  if (self) {
    _ads = [[FLTGoogleMobileAdsCollection alloc] init];
    NSObject<FlutterMethodCodec> *methodCodec = [FlutterStandardMethodCodec
        codecWithReaderWriter:[[FLTGoogleMobileAdsReaderWriter alloc] init]];
    _channel = [[FlutterMethodChannel alloc]
           initWithName:@"plugins.flutter.io/google_mobile_ads"
        binaryMessenger:binaryMessenger
                  codec:methodCodec];
  }
  return self;
}

- (id<FLTAd> _Nullable)adFor:(NSNumber *_Nonnull)adId {
  return [_ads objectForKey:adId];
}

- (NSNumber *_Nullable)adIdFor:(id<FLTAd> _Nonnull)ad {
  NSArray<NSNumber *> *keys = [_ads allKeysForObject:ad];

  if (keys.count > 1) {
    NSLog(@"%@Error: Multiple keys for a single ad.",
          NSStringFromClass([FLTAdInstanceManager class]));
  }

  if (keys.count > 0) {
    return keys[0];
  }

  return nil;
}

- (void)loadAd:(id<FLTAd> _Nonnull)ad {
  [_ads setObject:ad forKey:ad.adId];
  ad.manager = self;
  [ad load];
}

- (void)dispose:(NSNumber *_Nonnull)adId {
  [_ads removeObjectForKey:adId];
}

- (void)disposeAllAds {
  [_ads removeAllObjects];
}

- (void)showAdWithID:(NSNumber *_Nonnull)adId {
  id<FLTAdWithoutView> ad = (id<FLTAdWithoutView>)[self adFor:adId];

  if (!ad) {
    NSLog(@"Can't find ad with id: %@", adId);
    return;
  }

  [ad show];
}

- (void)onAdLoaded:(id<FLTAd> _Nonnull)ad
      responseInfo:(GADResponseInfo *_Nonnull)responseInfo {
  [_channel invokeMethod:@"onAdEvent"
               arguments:@{
                 @"adId" : ad.adId,
                 @"eventName" : @"onAdLoaded",
                 @"responseInfo" : [[FLTGADResponseInfo alloc]
                     initWithResponseInfo:responseInfo]
               }];
}

- (void)onAdFailedToLoad:(id<FLTAd> _Nonnull)ad error:(NSError *_Nonnull)error {
  [_channel invokeMethod:@"onAdEvent"
               arguments:@{
                 @"adId" : ad.adId,
                 @"eventName" : @"onAdFailedToLoad",
                 @"loadAdError" : [[FLTLoadAdError alloc] initWithError:error]
               }];
}

- (void)onAppEvent:(id<FLTAd> _Nonnull)ad
              name:(NSString *)name
              data:(NSString *)data {
  [_channel invokeMethod:@"onAdEvent"
               arguments:@{
                 @"adId" : ad.adId,
                 @"eventName" : @"onAppEvent",
                 @"name" : name,
                 @"data" : data
               }];
}

- (void)onNativeAdImpression:(FLTNativeAd *_Nonnull)ad {
  [self sendAdEvent:@"onNativeAdImpression" ad:ad];
}

- (void)onNativeAdWillPresentScreen:(FLTNativeAd *_Nonnull)ad {
  [self sendAdEvent:@"onNativeAdWillPresentScreen" ad:ad];
}

- (void)onNativeAdDidDismissScreen:(FLTNativeAd *_Nonnull)ad {
  [self sendAdEvent:@"onNativeAdDidDismissScreen" ad:ad];
}

- (void)onNativeAdWillDismissScreen:(FLTNativeAd *_Nonnull)ad {
  [self sendAdEvent:@"onNativeAdWillDismissScreen" ad:ad];
}

- (void)onRewardedAdUserEarnedReward:(FLTRewardedAd *_Nonnull)ad
                              reward:(FLTRewardItem *_Nonnull)reward {
  [_channel invokeMethod:@"onAdEvent"
               arguments:@{
                 @"adId" : ad.adId,
                 @"eventName" : @"onRewardedAdUserEarnedReward",
                 @"rewardItem" : reward,
               }];
}

- (void)onRewardedInterstitialAdUserEarnedReward:
            (FLTRewardedInterstitialAd *_Nonnull)ad
                                          reward:
                                              (FLTRewardItem *_Nonnull)reward {
  [_channel invokeMethod:@"onAdEvent"
               arguments:@{
                 @"adId" : ad.adId,
                 @"eventName" : @"onRewardedInterstitialAdUserEarnedReward",
                 @"rewardItem" : reward,
               }];
}

- (void)onPaidEvent:(id<FLTAd> _Nonnull)ad value:(FLTAdValue *_Nonnull)adValue {
  [_channel invokeMethod:@"onAdEvent"
               arguments:@{
                 @"adId" : ad.adId,
                 @"eventName" : @"onPaidEvent",
                 @"valueMicros" : adValue.valueMicros,
                 @"precision" : [NSNumber numberWithInteger:adValue.precision],
                 @"currencyCode" : adValue.currencyCode
               }];
}

- (void)onBannerImpression:(FLTBannerAd *_Nonnull)ad {
  [self sendAdEvent:@"onBannerImpression" ad:ad];
}

- (void)onBannerWillDismissScreen:(FLTBannerAd *)ad {
  [self sendAdEvent:@"onBannerWillDismissScreen" ad:ad];
}

- (void)onBannerDidDismissScreen:(FLTBannerAd *)ad {
  [self sendAdEvent:@"onBannerDidDismissScreen" ad:ad];
}

- (void)onBannerWillPresentScreen:(FLTBannerAd *_Nonnull)ad {
  [self sendAdEvent:@"onBannerWillPresentScreen" ad:ad];
}

- (void)adWillPresentFullScreenContent:(id<FLTAd> _Nonnull)ad {
  [self sendAdEvent:@"adWillPresentFullScreenContent" ad:ad];
}

- (void)adDidDismissFullScreenContent:(id<FLTAd> _Nonnull)ad {
  [self sendAdEvent:@"adDidDismissFullScreenContent" ad:ad];
}

- (void)adWillDismissFullScreenContent:(id<FLTAd> _Nonnull)ad {
  [self sendAdEvent:@"adWillDismissFullScreenContent" ad:ad];
}

- (void)adDidRecordImpression:(id<FLTAd> _Nonnull)ad {
  [self sendAdEvent:@"adDidRecordImpression" ad:ad];
}

- (void)adDidRecordClick:(id<FLTAd> _Nonnull)ad {
  [self sendAdEvent:@"adDidRecordClick" ad:ad];
}

- (void)didFailToPresentFullScreenContentWithError:(id<FLTAd> _Nonnull)ad
                                             error:(NSError *_Nonnull)error {
  [_channel invokeMethod:@"onAdEvent"
               arguments:@{
                 @"adId" : ad.adId,
                 @"eventName" : @"didFailToPresentFullScreenContentWithError",
                 @"error" : error
               }];
}

- (void)onFluidAdHeightChanged:(id<FLTAd> _Nonnull)ad height:(CGFloat)height {
  [_channel invokeMethod:@"onAdEvent"
               arguments:@{
                 @"adId" : ad.adId,
                 @"eventName" : @"onFluidAdHeightChanged",
                 @"height" : [[NSNumber alloc] initWithFloat:height]
               }];
}

- (void)onPlatformViewSizeChanged:(id<FLTAd> _Nonnull)ad
                            width:(CGFloat)width
                            height:(CGFloat)height {
  [_channel invokeMethod:@"onAdEvent"
               arguments:@{
                 @"adId" : ad.adId,
                 @"eventName" : @"onPlatformViewSizeChanged",
                 @"height" : [[NSNumber alloc] initWithFloat:height],
                 @"width" : [[NSNumber alloc] initWithFloat:width]
               }];
}

/// Sends an ad event with the provided name.
- (void)sendAdEvent:(NSString *_Nonnull)eventName ad:(id<FLTAd>)ad {
  [_channel invokeMethod:@"onAdEvent"
               arguments:@{
                 @"adId" : ad.adId,
                 @"eventName" : eventName,
               }];
}

@end

@implementation FLTGoogleMobileAdsViewFactory
- (instancetype)initWithManager:(FLTAdInstanceManager *_Nonnull)manager {
  self = [super init];
  if (self) {
    _manager = manager;
  }
  return self;
}

- (nonnull NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                            viewIdentifier:(int64_t)viewId
                                                 arguments:(id _Nullable)args {
  NSNumber *adId;
  NSObject<FlutterPlatformView> *view;
  if ([args isKindOfClass:[NSNumber class]]) {
    adId = args;
    view = (NSObject<FlutterPlatformView> *)[_manager adFor:adId];
  } else if ([args isKindOfClass:[NSDictionary class]]) {
    NSDictionary *argsDict = args;
    NSString *type = argsDict[@"type"];
    adId = argsDict[@"adId"];
    if ([type isEqual:@"AdWidget"]) {
      // TODO - migrate AdWidget here
    } else if ([type isEqual:@"AutoSizingAdWidget"]) {
      NSObject<FLTAd, FlutterPlatformView> *ad = (NSObject<FlutterPlatformView> *)[_manager adFor:adId];
      view = [[FLTAutoSizingPlatformView alloc] initWithAd:ad manager:_manager];
    } else {
      // TODO - handle errors
    }
  }
  
  if (!view) {
    NSString *reason = [NSString
        stringWithFormat:
            @"Could not find an ad with id: %@. Was this ad already disposed?",
            adId];
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:reason
                                 userInfo:nil];
  }
  return view;
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}
@end

@implementation FLTAutoSizingPlatformViewContainer
- (void)layoutSubviews {
  [super layoutSubviews];
  [self.delegate sizeDidChange:_adView.frame.size];
}

@end

@implementation FLTAutoSizingPlatformView {
  UIView *_containerView;
  FLTAdInstanceManager *_manager;
  NSObject<FLTAd, FlutterPlatformView> *_ad;
  CGSize _size;
}

- (instancetype _Nonnull )initWithAd:(NSObject<FLTAd, FlutterPlatformView> *_Nonnull)ad
                               manager:(FLTAdInstanceManager *_Nonnull)manager {
  self = [super init];
  if (self) {
    _ad = ad;
    _manager = manager;
    FLTAutoSizingPlatformViewContainer *container = [[FLTAutoSizingPlatformViewContainer alloc] initWithFrame:CGRectZero];
    container.adView = _ad.view;
    [container addSubview:_ad.view];
    container.delegate = self;
    _containerView = container;
  }
  return self;
}


#pragma mark - FLTAutoSizingPlatformViewContainerDelegate
- (void)sizeDidChange:(CGSize)size {
  if (_size.width == size.width && _size.height == size.height) {
    return;
  }
  _size = size;
  [_manager onPlatformViewSizeChanged:_ad width:size.width height:size.height];
}

#pragma mark - FlutterPlatformView

- (nonnull UIView *)view {
  return _containerView;
}

@end
