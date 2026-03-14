import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/board_theme.dart';
import '../utils/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  final BoardTheme currentTheme;
  final Function(BoardTheme) onThemeChanged;
  final bool? soundEnabled;
  final VoidCallback? onToggleSound;
  final AppLanguage? currentLanguage;
  final Function(AppLanguage)? onLanguageChanged;
  final AppLocalizations? loc;

  const SettingsScreen({
    Key? key,
    required this.currentTheme,
    required this.onThemeChanged,
    this.soundEnabled,
    this.onToggleSound,
    this.currentLanguage,
    this.onLanguageChanged,
    this.loc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = loc ?? AppLocalizations(AppLanguage.english);

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
              // ── Звук ────────────────────────────────────────────────────
              if (soundEnabled != null && onToggleSound != null) ...[
                _sectionTitle(l.soundSection),
                const SizedBox(height: 10),
                _card(
                  child: Row(
                    children: [
                      Icon(
                        soundEnabled!
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: soundEnabled! ? Colors.white : Colors.white38,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.gameSounds,
                          style: TextStyle(
                            color:
                            soundEnabled! ? Colors.white : Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Switch(
                        value: soundEnabled!,
                        onChanged: (_) => onToggleSound!(),
                        activeColor: GameConstants.boardColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Язык ────────────────────────────────────────────────────
              if (currentLanguage != null && onLanguageChanged != null) ...[
                _sectionTitle(l.languageSection),
                const SizedBox(height: 10),
                _card(
                  child: Column(
                    children: AppLanguage.values.map((lang) {
                      final isSelected = currentLanguage == lang;
                      return InkWell(
                        onTap: () => onLanguageChanged!(lang),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 10),
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
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Тема доски ───────────────────────────────────────────────
              _sectionTitle(l.boardThemeSection),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: BoardTheme.values.length,
                itemBuilder: (context, index) {
                  final theme = BoardTheme.values[index];
                  final themeData = BoardThemeData.getTheme(theme);
                  final isSelected = currentTheme == theme;

                  return GestureDetector(
                    onTap: () => onThemeChanged(theme),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                          isSelected ? Colors.white : Colors.transparent,
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
                              color:
                              isSelected ? Colors.white : Colors.white70,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 14),
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
      case AppLanguage.english:  return '🇬🇧';
      case AppLanguage.russian:  return '🇷🇺';
      case AppLanguage.hebrew:   return '🇮🇱';
      case AppLanguage.spanish:  return '🇪🇸';
      case AppLanguage.french:   return '🇫🇷';
      case AppLanguage.german:   return '🇩🇪';
      case AppLanguage.chinese:  return '🇨🇳';
    }
  }
}