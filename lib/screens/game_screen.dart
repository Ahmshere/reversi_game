import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';
import '../widgets/board_widget.dart';
import '../widgets/score_widget.dart';

/// Экран игры
class GameScreen extends StatelessWidget {
  final GameMode gameMode;

  const GameScreen({
    Key? key,
    required this.gameMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState()..setGameMode(gameMode),
      child: const _GameScreenContent(),
    );
  }
}

class _GameScreenContent extends StatelessWidget {
  const _GameScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'REVERSI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<GameState>(
            builder: (context, gameState, _) {
              return IconButton(
                icon: Icon(
                  gameState.showValidMoves
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: gameState.toggleShowValidMoves,
                tooltip: 'Toggle hints',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _showNewGameDialog(context),
            tooltip: 'New game',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<GameState>(
          builder: (context, gameState, _) {
            // Проверяем окончание игры
            if (gameState.isGameOver) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showGameOverDialog(context, gameState);
              });
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Счет
                  ScoreWidget(
                    blackScore: gameState.blackScore,
                    whiteScore: gameState.whiteScore,
                    currentPlayer: gameState.currentPlayer,
                  ),
                  const SizedBox(height: 20),

                  // Текущий игрок
                  _buildCurrentPlayerIndicator(gameState),
                  const SizedBox(height: 20),

                  // Доска
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: BoardWidget(
                          board: gameState.board,
                          validMoves: gameState.validMoves,
                          showValidMoves: gameState.showValidMoves,
                          onCellTap: (row, col) =>
                              _handleCellTap(context, gameState, row, col),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Информация о ходах
                  if (gameState.validMoves.isEmpty && !gameState.isGameOver)
                    _buildNoMovesWarning(gameState),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentPlayerIndicator(GameState gameState) {
    final isBlack = gameState.currentPlayer == Player.black;
    final color = isBlack
        ? GameConstants.blackPlayerColor
        : GameConstants.whitePlayerColor;
    final label = isBlack ? 'Black' : 'White';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$label\'s Turn',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMovesWarning(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No valid moves! Turn will be skipped.',
              style: TextStyle(
                color: Colors.orange.shade100,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCellTap(
      BuildContext context, GameState gameState, int row, int col) {
    if (gameState.isProcessing || !gameState.isValidMove(row, col)) {
      return;
    }

    gameState.makeMove(row, col);
  }

  void _showNewGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameConstants.backgroundColor,
        title: const Text(
          'New Game',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Start a new game? Current progress will be lost.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GameState>().newGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GameConstants.boardColor,
            ),
            child: const Text('NEW GAME'),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, GameState gameState) {
    final winnerText = gameState.getWinnerText();
    final blackScore = gameState.blackScore;
    final whiteScore = gameState.whiteScore;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: GameConstants.backgroundColor,
        title: Text(
          winnerText,
          style: GameConstants.titleStyle.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
              'Final Score',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFinalScore(
                  'Black',
                  blackScore,
                  GameConstants.blackPlayerColor,
                ),
                _buildFinalScore(
                  'White',
                  whiteScore,
                  GameConstants.whitePlayerColor,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to menu
            },
            child: const Text('MENU', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GameState>().newGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GameConstants.boardColor,
            ),
            child: const Text('PLAY AGAIN'),
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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
