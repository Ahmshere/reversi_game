import 'dart:math';
import '../models/board.dart';
import '../models/cell.dart';
import '../utils/constants.dart';

/// Уровень сложности AI
enum AIDifficulty {
  easy,
  medium,
  hard,
}

/// Простой AI противник для Reversi
class AIPlayer {
  final AIDifficulty difficulty;
  final Random _random = Random();

  AIPlayer({this.difficulty = AIDifficulty.medium});

  /// Получить лучший ход для AI
  Future<Cell?> getBestMove(Board board) async {
    // Задержка для более естественной игры
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));

    List<Cell> validMoves = board.getValidMoves();
    if (validMoves.isEmpty) {
      return null;
    }

    switch (difficulty) {
      case AIDifficulty.easy:
        return _getRandomMove(validMoves);
      case AIDifficulty.medium:
        return _getGreedyMove(board, validMoves);
      case AIDifficulty.hard:
        return _getStrategicMove(board, validMoves);
    }
  }

  /// Случайный ход (легкий уровень)
  Cell _getRandomMove(List<Cell> validMoves) {
    return validMoves[_random.nextInt(validMoves.length)];
  }

  /// Жадный ход - выбирает ход, который переворачивает больше фишек (средний уровень)
  Cell _getGreedyMove(Board board, List<Cell> validMoves) {
    Cell? bestMove;
    int maxFlips = 0;

    for (Cell move in validMoves) {
      // Создаем копию доски для тестирования
      Board testBoard = _copyBoard(board);
      List<Cell> flippedCells = testBoard.makeMove(move.row, move.col);

      if (flippedCells.length > maxFlips) {
        maxFlips = flippedCells.length;
        bestMove = move;
      }
    }

    return bestMove ?? validMoves[0];
  }

  /// Стратегический ход - учитывает позиции (углы, края) (сложный уровень)
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

  /// Оценить качество хода
  double _evaluateMove(Board board, Cell move) {
    double score = 0;

    // Весовая матрица позиций на доске
    // Углы - лучшие позиции (+100)
    // Края - хорошие позиции (+10)
    // Позиции рядом с углами - плохие позиции (-20)
    final List<List<int>> positionWeights = [
      [100, -20, 10, 5, 5, 10, -20, 100],
      [-20, -40, -5, -5, -5, -5, -40, -20],
      [10, -5, 5, 2, 2, 5, -5, 10],
      [5, -5, 2, 1, 1, 2, -5, 5],
      [5, -5, 2, 1, 1, 2, -5, 5],
      [10, -5, 5, 2, 2, 5, -5, 10],
      [-20, -40, -5, -5, -5, -5, -40, -20],
      [100, -20, 10, 5, 5, 10, -20, 100],
    ];

    // Базовая оценка - вес позиции
    score += positionWeights[move.row][move.col];

    // Дополнительная оценка - количество переворачиваемых фишек
    Board testBoard = _copyBoard(board);
    List<Cell> flippedCells = testBoard.makeMove(move.row, move.col);
    score += flippedCells.length * 5;

    // Бонус за захват углов
    if (_isCorner(move.row, move.col)) {
      score += 50;
    }

    // Бонус за захват краев
    if (_isEdge(move.row, move.col) && !_isNextToCorner(move.row, move.col)) {
      score += 15;
    }

    return score;
  }

  /// Проверка, является ли позиция углом
  bool _isCorner(int row, int col) {
    return (row == 0 || row == GameConstants.boardSize - 1) &&
        (col == 0 || col == GameConstants.boardSize - 1);
  }

  /// Проверка, является ли позиция краем
  bool _isEdge(int row, int col) {
    return row == 0 ||
        row == GameConstants.boardSize - 1 ||
        col == 0 ||
        col == GameConstants.boardSize - 1;
  }

  /// Проверка, находится ли позиция рядом с углом
  bool _isNextToCorner(int row, int col) {
    final corners = [
      [0, 0], [0, GameConstants.boardSize - 1],
      [GameConstants.boardSize - 1, 0],
      [GameConstants.boardSize - 1, GameConstants.boardSize - 1],
    ];

    for (var corner in corners) {
      int dr = (row - corner[0]).abs();
      int dc = (col - corner[1]).abs();
      if ((dr == 1 && dc == 0) ||
          (dr == 0 && dc == 1) ||
          (dr == 1 && dc == 1)) {
        return true;
      }
    }
    return false;
  }

  /// Создать копию доски для тестирования ходов
  Board _copyBoard(Board original) {
    Board copy = Board();
    
    // Копируем состояние каждой клетки
    for (int row = 0; row < GameConstants.boardSize; row++) {
      for (int col = 0; col < GameConstants.boardSize; col++) {
        copy.cells[row][col].player = original.cells[row][col].player;
      }
    }
    
    copy.currentPlayer = original.currentPlayer;
    return copy;
  }
}
