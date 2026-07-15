import 'dart:math';
import '../models/board.dart';
import '../models/cell.dart';
import '../utils/constants.dart';

/// Уровень сложности AI
enum AIDifficulty { easy, medium, hard }

/// Простой AI противник для Reversi
class AIPlayer {
  final AIDifficulty difficulty;
  final Random _random = Random();

  AIPlayer({this.difficulty = AIDifficulty.medium});

  Future<Cell?> getBestMove(Board board) async {
    await Future.delayed(Duration(milliseconds: 1200 + _random.nextInt(600)));
    List<Cell> validMoves = board.getValidMoves();
    if (validMoves.isEmpty) return null;

    switch (difficulty) {
      case AIDifficulty.easy:
        return _getRandomMove(validMoves);
      case AIDifficulty.medium:
        return _getGreedyMove(board, validMoves);
      case AIDifficulty.hard:
        return _getStrategicMove(board, validMoves);
    }
  }

  /// Быстрая подсказка «лучшего» хода — без искусственной задержки и
  /// независимо от выбранной сложности ИИ. Используется кнопкой "Hint".
  Cell? suggestBestMove(Board board) {
    final validMoves = board.getValidMoves();
    if (validMoves.isEmpty) return null;
    return _getStrategicMove(board, validMoves);
  }

  Cell _getRandomMove(List<Cell> validMoves) =>
      validMoves[_random.nextInt(validMoves.length)];

  Cell _getGreedyMove(Board board, List<Cell> validMoves) {
    Cell? bestMove;
    int maxFlips = 0;
    for (Cell move in validMoves) {
      Board testBoard = _copyBoard(board);
      // В режиме Хаос модификаторы тоже учитываются в копии
      MoveResult result = testBoard.makeMove(move.row, move.col);
      final total = result.flippedCells.length + result.explosiveFlipped.length;
      if (total > maxFlips) {
        maxFlips = total;
        bestMove = move;
      }
    }
    return bestMove ?? validMoves[0];
  }

  Cell _getStrategicMove(Board board, List<Cell> validMoves) {
    Cell? bestMove;
    double bestScore = double.negativeInfinity;
    for (Cell move in validMoves) {
      double score = _evaluateMove(board, move);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove ?? validMoves[0];
  }

  double _evaluateMove(Board board, Cell move) {
    double score = 0;
    const positionWeights = [
      [100, -20, 10, 5, 5, 10, -20, 100],
      [-20, -40, -5, -5, -5, -5, -40, -20],
      [10, -5, 5, 2, 2, 5, -5, 10],
      [5, -5, 2, 1, 1, 2, -5, 5],
      [5, -5, 2, 1, 1, 2, -5, 5],
      [10, -5, 5, 2, 2, 5, -5, 10],
      [-20, -40, -5, -5, -5, -5, -40, -20],
      [100, -20, 10, 5, 5, 10, -20, 100],
    ];

    score += positionWeights[move.row][move.col];

    // Бонус за взрывные клетки — AI видит что ход выгоднее
    if (board.getCell(move.row, move.col).cellType == CellType.explosive) {
      score += 20;
    }
    // Штраф за бонусные клетки для противника — AI избегает
    // (но сам AI хочет попасть на бонус тоже)
    if (board.getCell(move.row, move.col).cellType == CellType.bonus) {
      score += 15;
    }

    Board testBoard = _copyBoard(board);
    MoveResult result = testBoard.makeMove(move.row, move.col);
    score += (result.flippedCells.length + result.explosiveFlipped.length) * 5;

    if (_isCorner(move.row, move.col)) score += 50;
    if (_isEdge(move.row, move.col) && !_isNextToCorner(move.row, move.col)) {
      score += 15;
    }

    return score;
  }

  bool _isCorner(int row, int col) {
    return (row == 0 || row == GameConstants.boardSize - 1) &&
        (col == 0 || col == GameConstants.boardSize - 1);
  }

  bool _isEdge(int row, int col) {
    return row == 0 ||
        row == GameConstants.boardSize - 1 ||
        col == 0 ||
        col == GameConstants.boardSize - 1;
  }

  bool _isNextToCorner(int row, int col) {
    final corners = [
      [0, 0], [0, GameConstants.boardSize - 1],
      [GameConstants.boardSize - 1, 0],
      [GameConstants.boardSize - 1, GameConstants.boardSize - 1],
    ];
    for (var corner in corners) {
      int dr = (row - corner[0]).abs();
      int dc = (col - corner[1]).abs();
      if ((dr == 1 && dc == 0) || (dr == 0 && dc == 1) || (dr == 1 && dc == 1)) {
        return true;
      }
    }
    return false;
  }

  /// Создать полную копию доски (включая модификаторы клеток)
  Board _copyBoard(Board original) {
    Board copy = Board();
    for (int row = 0; row < GameConstants.boardSize; row++) {
      for (int col = 0; col < GameConstants.boardSize; col++) {
        copy.cells[row][col].player = original.cells[row][col].player;
        copy.cells[row][col].cellType = original.cells[row][col].cellType;
      }
    }
    copy.currentPlayer = original.currentPlayer;
    return copy;
  }
}