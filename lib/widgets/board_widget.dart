import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/cell.dart';
import '../utils/constants.dart';
import 'cell_widget.dart';

/// Виджет игровой доски
class BoardWidget extends StatelessWidget {
  final Board board;
  final List<Cell> validMoves;
  final bool showValidMoves;
  final Function(int row, int col) onCellTap;

  const BoardWidget({
    Key? key,
    required this.board,
    required this.validMoves,
    required this.showValidMoves,
    required this.onCellTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: GameConstants.gridLineColor,
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
            final isValid = showValidMoves &&
                validMoves.any((c) => c.row == row && c.col == col);

            return CellWidget(
              key: ValueKey('cell_${row}_$col'),
              cell: cell,
              isValidMove: isValid,
              onTap: () => onCellTap(row, col),
            );
          },
        ),
      ),
    );
  }
}
