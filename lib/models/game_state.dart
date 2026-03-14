import 'package:flutter/foundation.dart';
import 'board.dart';
import 'cell.dart';
import '../utils/constants.dart';
import '../utils/ai_player.dart';
import '../utils/board_theme.dart';

/// Режим игры
enum GameMode {
  vsPlayer, // Игрок против игрока
  vsAI, // Игрок против компьютера
}

/// Класс управления состоянием игры
class GameState extends ChangeNotifier {
  late Board _board;
  GameMode _gameMode = GameMode.vsPlayer;
  bool _showValidMoves = false; // По умолчанию выключены
  bool _isProcessing = false;
  late AIPlayer _aiPlayer;
  BoardTheme _boardTheme = BoardTheme.classic;

  GameState() {
    _board = Board();
    _aiPlayer = AIPlayer(difficulty: AIDifficulty.medium);
  }

  // Геттеры
  Board get board => _board;
  GameMode get gameMode => _gameMode;
  bool get showValidMoves => _showValidMoves;
  bool get isProcessing => _isProcessing;
  Player get currentPlayer => _board.currentPlayer;
  AIDifficulty get aiDifficulty => _aiPlayer.difficulty;
  BoardTheme get boardTheme => _boardTheme;

  int get blackScore => _board.countPieces(Player.black);
  int get whiteScore => _board.countPieces(Player.white);

  bool get isGameOver => _board.isGameOver();
  Player? get winner => _board.getWinner();

  List<Cell> get validMoves => _board.getValidMoves();

  /// Установить режим игры
  void setGameMode(GameMode mode) {
    _gameMode = mode;
    notifyListeners();
  }

  /// Установить сложность AI
  void setAIDifficulty(AIDifficulty difficulty) {
    _aiPlayer = AIPlayer(difficulty: difficulty);
    notifyListeners();
  }

  /// Установить тему доски
  void setBoardTheme(BoardTheme theme) {
    _boardTheme = theme;
    notifyListeners();
  }

  /// Переключить отображение валидных ходов
  void toggleShowValidMoves() {
    _showValidMoves = !_showValidMoves;
    notifyListeners();
  }

  /// Проверка валидности хода
  bool isValidMove(int row, int col) {
    return _board.isValidMove(row, col);
  }

  /// Сделать ход
  Future<List<Cell>> makeMove(int row, int col) async {
    if (_isProcessing || !isValidMove(row, col)) {
      return [];
    }

    _isProcessing = true;
    notifyListeners();

    // Небольшая задержка для плавности
    await Future.delayed(const Duration(milliseconds: 100));

    List<Cell> flippedCells = _board.makeMove(row, col);

    _isProcessing = false;
    notifyListeners();

    // Проверяем, есть ли ходы у следующего игрока
    if (!isGameOver && validMoves.isEmpty) {
      // Если нет ходов, пропускаем ход
      await Future.delayed(const Duration(milliseconds: 500));
      skipTurn();
    }

    // Если играем против AI и сейчас ход белых (AI)
    if (_gameMode == GameMode.vsAI &&
        currentPlayer == Player.white &&
        !isGameOver) {
      await _makeAIMove();
    }

    return flippedCells;
  }

  /// Ход AI
  Future<void> _makeAIMove() async {
    if (_isProcessing || isGameOver) {
      return;
    }

    _isProcessing = true;
    notifyListeners();

    // AI выбирает лучший ход
    Cell? aiMove = await _aiPlayer.getBestMove(_board);

    if (aiMove != null) {
      _board.makeMove(aiMove.row, aiMove.col);
      notifyListeners();

      // Проверяем, есть ли ходы у следующего игрока
      if (!isGameOver && validMoves.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        skipTurn();

        // Если после пропуска хода снова ход AI, делаем еще один ход
        if (currentPlayer == Player.white && !isGameOver) {
          await _makeAIMove();
        }
      }
    }

    _isProcessing = false;
    notifyListeners();
  }

  /// Пропустить ход
  void skipTurn() {
    _board.skipTurn();
    notifyListeners();
  }

  /// Начать новую игру
  void newGame({GameMode? mode}) {
    _board.reset();
    if (mode != null) {
      _gameMode = mode;
    }
    _isProcessing = false;
    notifyListeners();
  }

  /// Получить текст победителя
  String getWinnerText() {
    if (!isGameOver) {
      return '';
    }

    Player? gameWinner = winner;
    if (gameWinner == Player.black) {
      return 'Black Wins!';
    } else if (gameWinner == Player.white) {
      return 'White Wins!';
    } else {
      return 'Draw!';
    }
  }
}