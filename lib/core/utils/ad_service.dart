import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  static const String _bannerAdId   = 'ca-app-pub-4744122948371705/4470048459';
  static const String _rewardedAdId = 'ca-app-pub-4744122948371705/1564594220';
  static const String _testBannerId   = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  static bool get _isDebug {
    bool d = false;
    assert(() { d = true; return true; }());
    return d;
  }

  String get bannerAdUnitId   => _isDebug ? _testBannerId   : _bannerAdId;
  String get rewardedAdUnitId => _isDebug ? _testRewardedId : _rewardedAdId;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoaded = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadRewardedAd();
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedLoaded = false;
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isRewardedLoaded = false;
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoaded = false;
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  Future<void> showRewardedAd({
    required VoidCallback onComplete,
    required VoidCallback onSkipped,
  }) async {
    if (!_isRewardedLoaded || _rewardedAd == null) {
      onComplete();
      return;
    }
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) => onComplete(),
    );
  }

  bool get isRewardedReady => _isRewardedLoaded;
}
