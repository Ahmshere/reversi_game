import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';
import '../utils/board_theme.dart';
import '../utils/audio_service.dart';
import '../utils/app_localizations.dart';
import '../version.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'tutorial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BoardTheme _selectedTheme = BoardTheme.classic;
  final AudioService _audio = AudioService();
  AppLanguage _language = AppLanguage.english;

  AppLocalizations get _loc => AppLocalizations(_language);

  @override
  Widget build(BuildContext context) {
    final loc = _loc;

    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => _showSettings(context),
              tooltip: loc.settings,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  loc.appTitle,
                  style: GameConstants.titleStyle.copyWith(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.appSubtitle,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDecorativePiece(GameConstants.blackPlayerColor),
                    const SizedBox(width: 20),
                    _buildDecorativePiece(GameConstants.whitePlayerColor),
                  ],
                ),
                const SizedBox(height: 60),
                _buildMenuButton(
                  context,
                  label: loc.vsPlayer,
                  icon: Icons.people,
                  onPressed: () => _startGame(context, GameMode.vsPlayer),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  label: loc.vsComputer,
                  icon: Icons.computer,
                  onPressed: () => _startGame(context, GameMode.vsAI),
                ),
                const SizedBox(height: 40),
                TextButton(
                  onPressed: () => _showRules(context),
                  child: Text(
                    loc.howToPlay,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'v$appVersion',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativePiece(Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required VoidCallback onPressed,
      }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(label, style: GameConstants.buttonStyle),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context, GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          gameMode: mode,
          initialTheme: _selectedTheme,
          initialLanguage: _language,
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, setModalState) => SettingsScreen(
            currentTheme: _selectedTheme,
            soundEnabled: _audio.soundEnabled,
            onToggleSound: () {
              _audio.setSoundEnabled(!_audio.soundEnabled);
              setModalState(() {});
              setState(() {});
            },
            currentLanguage: _language,
            onLanguageChanged: (lang) {
              setModalState(() => _language = lang);
              setState(() => _language = lang);
            },
            onThemeChanged: (theme) {
              setState(() => _selectedTheme = theme);
              Navigator.pop(context);
            },
            loc: _loc,
          ),
        ),
      ),
    );
  }

  void _showRules(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TutorialScreen(loc: _loc),
      ),
    );
  }
}