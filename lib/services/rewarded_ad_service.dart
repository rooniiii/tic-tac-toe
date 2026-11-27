import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  RewardedAd? _rewardedAd;

  bool _isLoading = false;
  bool _isShowing = false;

  Timer? _retryTimer;

  void Function()? onAdStateChanged;
  void Function()? onAdClosed;

  static const String _adUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  static final RewardedAdService instance =
  RewardedAdService._internal();

  factory RewardedAdService() => instance;

  RewardedAdService._internal();

  bool get isAdReady => _rewardedAd != null;

  void loadAd() {
    if (_isLoading || _rewardedAd != null || _isShowing) {
      return;
    }

    _retryTimer?.cancel();
    _retryTimer = null;

    _isLoading = true;
    onAdStateChanged?.call();

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          onAdStateChanged?.call();
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoading = false;

          onAdStateChanged?.call();

          // Retry automatically after a short delay.
          _retryTimer?.cancel();
          _retryTimer = Timer(
            const Duration(seconds: 5),
            loadAd,
          );
        },
      ),
    );
  }

  void showAd({
    required void Function() onRewardEarned,
    required void Function() onAdUnavailable,
  }) {
    if (_isShowing) return;

    final ad = _rewardedAd;

    if (ad == null) {
      onAdUnavailable();
      loadAd();
      return;
    }

    _rewardedAd = null;
    _isShowing = true;

    onAdStateChanged?.call();

    ad.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _isShowing = false;

            onAdStateChanged?.call();
            onAdClosed?.call();

            // Preload the next ad.
            loadAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _isShowing = false;

            onAdStateChanged?.call();
            onAdClosed?.call();
            onAdUnavailable();

            loadAd();
          },
        );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        onRewardEarned();
      },
    );
  }

  void dispose() {
    // Do not destroy the shared ad when a game screen closes.
    onAdStateChanged = null;
    onAdClosed = null;
  }
}