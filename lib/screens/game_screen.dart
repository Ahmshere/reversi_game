import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';
import '../utils/board_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/board_widget.dart';
import '../widgets/score_widget.dart';
import 'settings_screen.dart';

class GameScreen extends StatelessWidget {
  final GameMode gameMode;
  final BoardTheme initialTheme;
  final AppLanguage initialLanguage;
  final bool isModifierMode;
  final Function(AppLanguage)? onLanguageChanged;

  const GameScreen({
    Key? key,
    required this.gameMode,
    this.initialTheme = BoardTheme.classic,
    this.initialLanguage = AppLanguage.english,
    this.isModifierMode = false,
    this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState()
        ..setGameMode(gameMode)
        ..setBoardTheme(initialTheme)
        ..setLanguage(initialLanguage)
        ..setModifierMode(isModifierMode),
      child: _GameScreenContent(onLanguageChanged: onLanguageChanged),
    );
  }
}

class _GameScreenContent extends StatelessWidget {
  final Function(AppLanguage)? onLanguageChanged;

  const _GameScreenContent({Key? key, this.onLanguageChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        final loc = gameState.loc;

        return WillPopScope(
          onWillPop: () async {
            if (gameState.isGameOver) return true;
            return await _showExitConfirmation(context, loc) ?? false;
          },
          child: Scaffold(
            backgroundColor: GameConstants.backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () async {
                  if (gameState.isGameOver) {
                    Navigator.pop(context);
                    return;
                  }
                  final shouldExit =
                      await _showExitConfirmation(context, loc) ?? false;
                  if (shouldExit && context.mounted) Navigator.pop(context);
                },
              ),
              title: Text(
                loc.appTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    gameState.showValidMoves
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: gameState.toggleShowValidMoves,
                  tooltip: loc.toggleHints,
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => _showSettings(context, gameState),
                  tooltip: loc.settings,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => _showNewGameDialog(context, loc),
                  tooltip: loc.newGame,
                ),
              ],
            ),
            body: SafeArea(
              child: Builder(
                builder: (context) {
                  if (gameState.isGameOver) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showGameOverDialog(context, gameState, loc);
                    });
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 12.0),
                          child: Column(
                            children: [
                              ScoreWidget(
                                blackScore: gameState.blackScore,
                                whiteScore: gameState.whiteScore,
                                currentPlayer: gameState.currentPlayer,
                                blackLabel: loc.blackPlayer,
                                whiteLabel: loc.whitePlayer,
                              ),
                              const SizedBox(height: 12),
                              _buildCurrentPlayerIndicator(gameState, loc),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: 1.0,
                                    child: BoardWidget(
                                      board: gameState.board,
                                      validMoves: gameState.validMoves,
                                      showValidMoves: gameState.showValidMoves,
                                      onCellTap: (row, col) => _handleCellTap(
                                          context, gameState, row, col),
                                      boardTheme: gameState.boardTheme,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Баннер "нет ходов" — виден 3 секунды
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                child: gameState.showSkipBanner
                                    ? _buildNoMovesWarning(loc)
                                    : const SizedBox.shrink(),
                              ),
                              // Баннер сработавшего модификатора (Chaos Mode)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: gameState.showModifierBanner
                                    ? _buildModifierBanner(
                                    gameState.modifierBannerText)
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 60,
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Text(
                            loc.adPlaceholder,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentPlayerIndicator(GameState gameState, loc) {
    final isBlack = gameState.currentPlayer == Player.black;
    final color = isBlack
        ? GameConstants.blackPlayerColor
        : GameConstants.whitePlayerColor;
    final label =
    isBlack ? loc.blackPlayer : loc.whitePlayer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            loc.turnOf(label),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMovesWarning(loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              loc.noValidMoves,
              style: TextStyle(color: Colors.orange.shade100, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModifierBanner(String text) {
    return Container(
      key: ValueKey(text),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurpleAccent, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.deepPurpleAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCellTap(
      BuildContext context, GameState gameState, int row, int col) {
    if (gameState.isProcessing || !gameState.isValidMove(row, col)) return;
    gameState.makeMove(row, col);
  }

  void _showSettings(BuildContext context, GameState gameState) {
    final loc = gameState.loc;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          currentTheme: gameState.boardTheme,
          soundEnabled: gameState.soundEnabled,
          onToggleSound: gameState.toggleSound,
          currentLanguage: gameState.language,
          onLanguageChanged: (lang) {
            gameState.setLanguage(lang);
            onLanguageChanged?.call(lang);
          },
          onThemeChanged: (theme) {
            gameState.setBoardTheme(theme);
            Navigator.pop(context);
          },
          loc: loc,
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmation(BuildContext context, loc) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameConstants.backgroundColor,
        title: Text(loc.leaveGameTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(loc.leaveGameConfirm,
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.stay,
                style: const TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.8)),
            child: Text(loc.leave),
          ),
        ],
      ),
    );
  }

  void _showNewGameDialog(BuildContext context, loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameConstants.backgroundColor,
        title: Text(loc.newGameTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(loc.newGameConfirm,
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel,
                style: const TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GameState>().newGame();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: GameConstants.boardColor),
            child: Text(loc.confirm),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(
      BuildContext context, GameState gameState, loc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameConstants.backgroundColor,
        title: Text(
          gameState.getWinnerText(),
          style: GameConstants.titleStyle.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(loc.finalScore,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFinalScore(loc.blackPlayer, gameState.blackScore,
                    GameConstants.blackPlayerColor),
                _buildFinalScore(loc.whitePlayer, gameState.whiteScore,
                    GameConstants.whitePlayerColor),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child:
            Text(loc.menu, style: const TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GameState>().newGame();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: GameConstants.boardColor),
            child: Text(loc.playAgain),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalScore(String label, int score, Color color) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(score.toString(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}