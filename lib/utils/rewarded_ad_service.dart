import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Сервис показа Rewarded-рекламы (вознаграждение за просмотр).
/// Используется для платной отмены хода (Undo) — игрок смотрит
/// короткий ролик и получает возможность отменить последний ход.
class RewardedAdService {
  static final RewardedAdService _instance = RewardedAdService._internal();
  factory RewardedAdService() => _instance;
  RewardedAdService._internal();

  RewardedAd? _ad;
  bool _isLoading = false;

  /// Android — боевой Rewarded Ad Unit ID (AdMob).
  /// iOS — пока тестовый ID от Google (замените, когда заведёте iOS-блок
  /// в AdMob; заодно нужно добавить GADApplicationIdentifier в Info.plist).
  static String get _adUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9604144074094777/6663175919';
    } else if (Platform.isIOS) {
      // TODO: заменить на боевой Rewarded Ad Unit ID для iOS
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return 'ca-app-pub-9604144074094777/6663175919';
  }

  bool get isReady => _ad != null;

  /// Заранее загружает рекламу, чтобы к моменту нажатия Undo она уже была
  /// готова к показу. Безопасно вызывать многократно.
  Future<void> preload() async {
    if (_ad != null || _isLoading) return;
    _isLoading = true;
    try {
      await RewardedAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _ad = ad;
            _isLoading = false;
          },
          onAdFailedToLoad: (error) {
            _ad = null;
            _isLoading = false;
          },
        ),
      );
    } catch (_) {
      _isLoading = false;
    }
  }

  /// Показывает рекламу. Возвращает true, если пользователь досмотрел
  /// ролик до конца и заработал награду (то есть можно выполнять Undo).
  Future<bool> show() async {
    if (_ad == null && !_isLoading) {
      await preload();
    }
    // Даём рекламе немного времени догрузиться, если preload() не был
    // вызван заранее (например, первый запуск экрана игры).
    int attempts = 0;
    while (_ad == null && _isLoading && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 300));
      attempts++;
    }

    final ad = _ad;
    if (ad == null) return false;
    _ad = null; // использованную рекламу больше не переиспользуем

    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preload(); // сразу готовим следующий показ
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        preload();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await ad.show(onUserEarnedReward: (ad, reward) {
        if (!completer.isCompleted) completer.complete(true);
      });
    } catch (_) {
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future;
  }
}
