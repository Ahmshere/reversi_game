import 'package:shared_preferences/shared_preferences.dart';
import 'ai_player.dart';
import 'board_theme.dart';
import 'app_localizations.dart';

/// Сервис хранения пользовательских настроек (тема доски, язык, сложность ИИ).
/// Сохраняет значения в SharedPreferences, чтобы они не сбрасывались
/// при перезапуске приложения. Звук хранится отдельно в AudioService.
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const _kThemeKey = 'settings_board_theme';
  static const _kLanguageKey = 'settings_language';
  static const _kDifficultyKey = 'settings_ai_difficulty';

  BoardTheme boardTheme = BoardTheme.night;
  AppLanguage language = AppLanguage.english;
  AIDifficulty aiDifficulty = AIDifficulty.medium;

  bool _loaded = false;

  /// Вызвать один раз при старте приложения (в main.dart), до runApp().
  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeName = prefs.getString(_kThemeKey);
      if (themeName != null) {
        boardTheme = BoardTheme.values.firstWhere(
          (t) => t.name == themeName,
          orElse: () => boardTheme,
        );
      }

      final langName = prefs.getString(_kLanguageKey);
      if (langName != null) {
        language = AppLanguage.values.firstWhere(
          (l) => l.name == langName,
          orElse: () => language,
        );
      }

      final diffName = prefs.getString(_kDifficultyKey);
      if (diffName != null) {
        aiDifficulty = AIDifficulty.values.firstWhere(
          (d) => d.name == diffName,
          orElse: () => aiDifficulty,
        );
      }
    } catch (_) {
      // Если чтение не удалось — остаёмся на значениях по умолчанию.
    }
    _loaded = true;
  }

  Future<void> setBoardTheme(BoardTheme theme) async {
    boardTheme = theme;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemeKey, theme.name);
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage lang) async {
    language = lang;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLanguageKey, lang.name);
    } catch (_) {}
  }

  Future<void> setAIDifficulty(AIDifficulty difficulty) async {
    aiDifficulty = difficulty;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kDifficultyKey, difficulty.name);
    } catch (_) {}
  }
}
