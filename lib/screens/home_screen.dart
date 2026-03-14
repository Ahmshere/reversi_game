import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';
import '../utils/board_theme.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

/// Главный экран с меню
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BoardTheme _selectedTheme = BoardTheme.classic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Кнопка настроек
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettings(context),
            tooltip: 'Settings',
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
                // Заголовок
                Text(
                  'REVERSI',
                  style: GameConstants.titleStyle.copyWith(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  'Classic Othello',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 60),

                // Декоративные фишки
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDecorativePiece(GameConstants.blackPlayerColor),
                    const SizedBox(width: 20),
                    _buildDecorativePiece(GameConstants.whitePlayerColor),
                  ],
                ),
                const SizedBox(height: 60),

                // Кнопки выбора режима
                _buildMenuButton(
                  context,
                  label: 'VS PLAYER',
                  icon: Icons.people,
                  onPressed: () => _startGame(context, GameMode.vsPlayer),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  label: 'VS COMPUTER',
                  icon: Icons.computer,
                  onPressed: () => _startGame(context, GameMode.vsAI),
                ),
                const SizedBox(height: 40),

                // Правила
                TextButton(
                  onPressed: () => _showRules(context),
                  child: Text(
                    'How to Play',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
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
            Text(
              label,
              style: GameConstants.buttonStyle,
            ),
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
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          currentTheme: _selectedTheme,
          onThemeChanged: (theme) {
            setState(() {
              _selectedTheme = theme;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameConstants.backgroundColor,
        title: const Text(
          'How to Play',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '1. Players take turns placing pieces\n\n'
                    '2. Trap opponent\'s pieces between yours\n\n'
                    '3. Trapped pieces flip to your color\n\n'
                    '4. You must flip at least one piece per turn\n\n'
                    '5. If you can\'t move, turn is skipped\n\n'
                    '6. Most pieces at the end wins!',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}