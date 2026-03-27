import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/cell.dart';
import '../utils/constants.dart';
import '../utils/board_theme.dart';
import 'cell_widget.dart';

class BoardWidget extends StatelessWidget {
  final Board board;
  final List<Cell> validMoves;
  final bool showValidMoves;
  final Function(int row, int col) onCellTap;
  final BoardTheme boardTheme;
  final Cell? lastAIMove;   // ← клетка куда ходит / походил ИИ
  final bool isAIThinking;  // ← ИИ думает — подсвечиваем мигающим контуром

  const BoardWidget({
    Key? key,
    required this.board,
    required this.validMoves,
    required this.showValidMoves,
    required this.onCellTap,
    this.boardTheme = BoardTheme.classic,
    this.lastAIMove,
    this.isAIThinking = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = BoardThemeData.getTheme(boardTheme);

    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: themeData.gridLineColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: GameConstants.boardSize,
          ),
          itemCount: GameConstants.boardSize * GameConstants.boardSize,
          itemBuilder: (context, index) {
            final row = index ~/ GameConstants.boardSize;
            final col = index % GameConstants.boardSize;
            final cell = board.getCell(row, col);

            final isValidMove = validMoves.any((c) => c.row == row && c.col == col);
            final showHint = showValidMoves && isValidMove;

            // Подсветка хода ИИ
            final isAITarget = lastAIMove != null &&
                lastAIMove!.row == row &&
                lastAIMove!.col == col;

            return CellWidget(
              key: ValueKey('cell_${row}_$col'),
              cell: cell,
              isValidMove: isValidMove,
              showHint: showHint,
              onTap: () => onCellTap(row, col),
              boardColor: themeData.boardColor,
              gridLineColor: themeData.gridLineColor,
              hintColor: themeData.hintColor,
              isAITarget: isAITarget,
              isAIThinking: isAIThinking && isAITarget,
            );
          },
        ),
      ),
    );
  }
}