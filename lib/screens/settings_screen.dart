import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/board_theme.dart';
import '../utils/app_localizations.dart';
import '../utils/ai_player.dart';

class SettingsScreen extends StatefulWidget {
  final BoardTheme currentTheme;
  final Function(BoardTheme) onThemeChanged;
  final bool? soundEnabled;
  final VoidCallback? onToggleSound;
  final AppLanguage? currentLanguage;
  final Function(AppLanguage)? onLanguageChanged;
  final AIDifficulty? currentDifficulty;
  final Function(AIDifficulty)? onDifficultyChanged;
  final AppLocalizations? loc;

  const SettingsScreen({
    Key? key,
    required this.currentTheme,
    required this.onThemeChanged,
    this.soundEnabled,
    this.onToggleSound,
    this.currentLanguage,
    this.onLanguageChanged,
    this.currentDifficulty,
    this.onDifficultyChanged,
    this.loc,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppLanguage _currentLang;
  late AppLocalizations _loc;
  late bool _soundEnabled;
  late AIDifficulty _difficulty;

  @override
  void initState() {
    super.initState();
    _currentLang = widget.currentLanguage ?? AppLanguage.english;
    _loc = AppLocalizations(_currentLang);
    _soundEnabled = widget.soundEnabled ?? true;
    _difficulty = widget.currentDifficulty ?? AIDifficulty.medium;
  }

  void _toggleSound() {
    setState(() => _soundEnabled = !_soundEnabled);
    widget.onToggleSound?.call();
  }

  void _selectLanguage(AppLanguage lang) {
    setState(() {
      _currentLang = lang;
      _loc = AppLocalizations(lang);
    });
    widget.onLanguageChanged?.call(lang);
  }

  void _selectDifficulty(AIDifficulty d) {
    setState(() => _difficulty = d);
    widget.onDifficultyChanged?.call(d);
  }

  String _difficultyLabel(AppLocalizations l, AIDifficulty d) {
    switch (d) {
      case AIDifficulty.easy: return l.difficultyEasy;
      case AIDifficulty.medium: return l.difficultyMedium;
      case AIDifficulty.hard: return l.difficultyHard;
    }
  }

  IconData _difficultyIcon(AIDifficulty d) {
    switch (d) {
      case AIDifficulty.easy: return Icons.sentiment_satisfied_alt_rounded;
      case AIDifficulty.medium: return Icons.balance_rounded;
      case AIDifficulty.hard: return Icons.local_fire_department_rounded;
    }
  }

  Color _difficultyColor(AIDifficulty d) {
    switch (d) {
      case AIDifficulty.easy: return const Color(0xFF27AE60);
      case AIDifficulty.medium: return const Color(0xFFF1C40F);
      case AIDifficulty.hard: return const Color(0xFFE74C3C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = _loc;

    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.settings,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // ── Звук ──────────────────────────────────────────────────────
              if (widget.soundEnabled != null && widget.onToggleSound != null) ...[
                _sectionTitle(l.soundSection),
                const SizedBox(height: 10),
                _card(
                  child: Row(
                    children: [
                      Icon(
                        _soundEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: _soundEnabled ? Colors.white : Colors.white38,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.gameSounds,
                          style: TextStyle(
                            color: _soundEnabled ? Colors.white : Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Switch(
                        value: _soundEnabled,
                        onChanged: (_) => _toggleSound(),
                        activeColor: GameConstants.boardColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Язык ──────────────────────────────────────────────────────
              if (widget.currentLanguage != null &&
                  widget.onLanguageChanged != null) ...[
                _sectionTitle(l.languageSection),
                const SizedBox(height: 10),
                _card(
                  child: Column(
                    children: AppLanguage.values.map((lang) {
                      final isSelected = _currentLang == lang;
                      return InkWell(
                        onTap: () => _selectLanguage(lang),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.07)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _langFlag(lang),
                                style: const TextStyle(fontSize: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  AppLocalizations.languageNames[lang]!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: isSelected
                                    ? const Icon(Icons.check_circle_rounded,
                                    key: ValueKey('check'),
                                    color: Color(0xFF27AE60),
                                    size: 20)
                                    : const SizedBox(
                                    key: ValueKey('empty'),
                                    width: 20),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Сложность ИИ ──────────────────────────────────────────────
              if (widget.currentDifficulty != null &&
                  widget.onDifficultyChanged != null) ...[
                _sectionTitle(l.aiDifficultySection),
                const SizedBox(height: 10),
                _card(
                  child: Column(
                    children: AIDifficulty.values.map((d) {
                      final isSelected = _difficulty == d;
                      return InkWell(
                        onTap: () => _selectDifficulty(d),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.07)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(_difficultyIcon(d),
                                  color: _difficultyColor(d), size: 20),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  _difficultyLabel(l, d),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: isSelected
                                    ? const Icon(Icons.check_circle_rounded,
                                    key: ValueKey('check'),
                                    color: Color(0xFF27AE60),
                                    size: 20)
                                    : const SizedBox(
                                    key: ValueKey('empty'),
                                    width: 20),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Тема доски ────────────────────────────────────────────────
              _sectionTitle(l.boardThemeSection),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: BoardTheme.values.length,
                itemBuilder: (context, index) {
                  final theme = BoardTheme.values[index];
                  final themeData = BoardThemeData.getTheme(theme);
                  final isSelected = widget.currentTheme == theme;

                  return GestureDetector(
                    onTap: () => widget.onThemeChanged(theme),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isSelected ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF27AE60)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 50,
                            decoration: BoxDecoration(
                              color: themeData.boardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: themeData.gridLineColor, width: 2),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: GameConstants.blackPlayerColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: GameConstants.whitePlayerColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            themeData.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: isSelected
                                ? const Icon(Icons.check_circle_rounded,
                                key: ValueKey('check'),
                                color: Color(0xFF27AE60),
                                size: 14)
                                : const SizedBox(
                                key: ValueKey('empty'), height: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );

  String _langFlag(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.english: return '🇬🇧';
      case AppLanguage.russian: return '🇷🇺';
      case AppLanguage.hebrew:  return '🇮🇱';
      case AppLanguage.spanish: return '🇪🇸';
      case AppLanguage.french:  return '🇫🇷';
      case AppLanguage.german:  return '🇩🇪';
      case AppLanguage.chinese: return '🇨🇳';
    }
  }
}