import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Виджет баннерной рекламы Google AdMob.
class AdBannerWidget extends StatefulWidget {
  /// Высота баннера в dp (обычно 50 для BANNER, 90 для LEADERBOARD)
  final double height;

  const AdBannerWidget({Key? key, this.height = 50}) : super(key: key);

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  /// ── Тестовые ID (замените на боевые перед релизом) ───────────────────────
  ///
  /// Android test ID: ca-app-pub-3940256099942544/6300978111
  /// iOS test ID:     ca-app-pub-3940256099942544/2934735716

  static String get _adUnitId {
    if (Platform.isAndroid) {
      // TODO: заменить на боевой Android Ad Unit ID
      return 'ca-app-pub-9604144074094777/9180577987';
    } else if (Platform.isIOS) {
      // TODO: заменить на боевой iOS Ad Unit ID
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    // fallback
    return 'ca-app-pub-9604144074094777/9180577987';
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner, // 320×50
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          // Молча игнорируем — баннер просто остаётся скрытым
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Всегда резервируем место нужной высоты, чтобы layout не прыгал
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: _isLoaded && _bannerAd != null
          ? AdWidget(ad: _bannerAd!)
          : const SizedBox.shrink(), // пустое место пока грузится
    );
  }
}