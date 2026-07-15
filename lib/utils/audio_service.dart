import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис управления звуками игры
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static const _kSoundEnabledKey = 'settings_sound_enabled';

  bool _soundEnabled = true;

  // Увеличенный пул плееров для надёжного воспроизведения
  final List<AudioPlayer> _pool = List.generate(8, (_) => AudioPlayer());
  int _poolIndex = 0;

  bool get soundEnabled => _soundEnabled;

  /// Загружает сохранённую настройку звука. Вызывается один раз при
  /// старте приложения, до runApp().
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool(_kSoundEnabledKey) ?? true;
    } catch (_) {
      // Оставляем значение по умолчанию (звук включён)
    }
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(_kSoundEnabledKey, enabled))
        .catchError((_) {});
  }

  Future<void> playMove() async {
    if (!_soundEnabled) return;
    await _play('sounds/move.mp3');
  }

  Future<void> playFlip() async {
    if (!_soundEnabled) return;
    await _play('sounds/flip.mp3');
  }

  Future<void> playWin() async {
    if (!_soundEnabled) return;
    await _play('sounds/win.mp3');
  }

  Future<void> playLose() async {
    if (!_soundEnabled) return;
    await _play('sounds/lose.mp3');
  }

  Future<void> playDraw() async {
    if (!_soundEnabled) return;
    await _play('sounds/draw.mp3');
  }

  Future<void> playSkipTurn() async {
    if (!_soundEnabled) return;
    await _play('sounds/skip.mp3');
  }

  Future<void> playExplosion() async {
    if (!_soundEnabled) return;
    await _play('sounds/expl.ogg');
  }

  Future<void> playTrapdoor() async {
    if (!_soundEnabled) return;
    await _play('sounds/trapdoor.ogg');
  }

  Future<void> playStar() async {
    if (!_soundEnabled) return;
    await _play('sounds/star.ogg');
  }

  Future<void> playFirework() async {
    if (!_soundEnabled) return;
    await _play('sounds/firework.ogg');
  }

  Future<void> _play(String assetPath) async {
    try {
      final player = _pool[_poolIndex % _pool.length];
      _poolIndex++;
      // Останавливаем предыдущий звук на этом плеере и сразу играем новый
      await player.stop();
      await player.play(AssetSource(assetPath));
    } catch (_) {
      // Игнорируем ошибки воспроизведения
    }
  }

  void dispose() {
    for (final p in _pool) {
      p.dispose();
    }
  }
}