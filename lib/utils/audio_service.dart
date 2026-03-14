import 'package:audioplayers/audioplayers.dart';

/// Сервис управления звуками игры
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _soundEnabled = true;

  // Пул плееров для одновременного воспроизведения
  final List<AudioPlayer> _pool = List.generate(4, (_) => AudioPlayer());
  int _poolIndex = 0;

  bool get soundEnabled => _soundEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
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

  Future<void> _play(String assetPath) async {
    try {
      final player = _pool[_poolIndex % _pool.length];
      _poolIndex++;
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