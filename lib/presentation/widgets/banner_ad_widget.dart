import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/utils/ad_service.dart';
import '../../core/theme/app_theme.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});
  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    final banner = BannerAd(
      adUnitId: AdService.instance.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() { _bannerAd = ad as BannerAd; _isLoaded = true; });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          // Retry setelah 30 detik
          Future.delayed(const Duration(seconds: 30), () {
            if (mounted) _loadBanner();
          });
        },
      ),
    );
    banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Selalu tampilkan container - kalau iklan belum load tampilkan placeholder
    return Container(
      width: double.infinity,
      height: 60,
      color: Colors.white,
      child: _isLoaded && _bannerAd != null
          ? AdWidget(ad: _bannerAd!)
          : Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: const Center(
                child: Text(
                  'Advertisement',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
    );
  }
}
