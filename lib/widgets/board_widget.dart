import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/cell.dart';
import '../utils/constants.dart';
import '../utils/board_theme.dart';
import 'cell_widget.dart';

/// Виджет игровой доски
class BoardWidget extends StatelessWidget {
  final Board board;
  final List<Cell> validMoves;
  final bool showValidMoves;
  final Function(int row, int col) onCellTap;
  final BoardTheme boardTheme;

  const BoardWidget({
    Key? key,
    required this.board,
    required this.validMoves,
    required this.showValidMoves,
    required this.onCellTap,
    this.boardTheme = BoardTheme.classic,
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
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemCount: GameConstants.boardSize * GameConstants.boardSize,
          itemBuilder: (context, index) {
            final row = index ~/ GameConstants.boardSize;
            final col = index % GameConstants.boardSize;
            final cell = board.getCell(row, col);

            // Проверяем, является ли клетка валидным ходом
            final isValidMove = validMoves.any((c) => c.row == row && c.col == col);

            // Показываем подсказку ТОЛЬКО если включены подсказки И это валидный ход
            final showHint = showValidMoves && isValidMove;

            return CellWidget(
              key: ValueKey('cell_${row}_$col'),
              cell: cell,
              isValidMove: isValidMove,  // ← Кликабельность (всегда для валидных ходов)
              showHint: showHint,         // ← Отображение подсказки (только когда включено)
              onTap: () => onCellTap(row, col),
              boardColor: themeData.boardColor,
              gridLineColor: themeData.gridLineColor,
            );
          },
        ),
      ),
    );
  }
}