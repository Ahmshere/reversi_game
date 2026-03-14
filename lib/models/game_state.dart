import 'package:flutter/foundation.dart';
import 'board.dart';
import 'cell.dart';
import '../utils/constants.dart';
import '../utils/ai_player.dart';
import '../utils/board_theme.dart';
import '../utils/audio_service.dart';
import '../utils/app_localizations.dart';

/// Режим игры
enum GameMode {
  vsPlayer,
  vsAI,
}

/// Класс управления состоянием игры
class GameState extends ChangeNotifier {
  late Board _board;
  GameMode _gameMode = GameMode.vsPlayer;
  bool _showValidMoves = false;
  bool _isProcessing = false;
  bool _showSkipBanner = false;
  late AIPlayer _aiPlayer;
  BoardTheme _boardTheme = BoardTheme.classic;
  final AudioService _audio = AudioService();
  AppLanguage _language = AppLanguage.english;

  GameState() {
    _board = Board();
    _aiPlayer = AIPlayer(difficulty: AIDifficulty.medium);
  }

  // Геттеры
  Board get board => _board;
  GameMode get gameMode => _gameMode;
  bool get showValidMoves => _showValidMoves;
  bool get isProcessing => _isProcessing;
  bool get showSkipBanner => _showSkipBanner;
  Player get currentPlayer => _board.currentPlayer;
  AIDifficulty get aiDifficulty => _aiPlayer.difficulty;
  BoardTheme get boardTheme => _boardTheme;
  bool get soundEnabled => _audio.soundEnabled;
  AppLanguage get language => _language;
  AppLocalizations get loc => AppLocalizations(_language);

  int get blackScore => _board.countPieces(Player.black);
  int get whiteScore => _board.countPieces(Player.white);

  bool get isGameOver => _board.isGameOver();
  Player? get winner => _board.getWinner();

  List<Cell> get validMoves => _board.getValidMoves();

  void setGameMode(GameMode mode) {
    _gameMode = mode;
    notifyListeners();
  }

  void setAIDifficulty(AIDifficulty difficulty) {
    _aiPlayer = AIPlayer(difficulty: difficulty);
    notifyListeners();
  }

  void setBoardTheme(BoardTheme theme) {
    _boardTheme = theme;
    notifyListeners();
  }

  void toggleSound() {
    _audio.setSoundEnabled(!_audio.soundEnabled);
    notifyListeners();
  }

  void setLanguage(AppLanguage lang) {
    _language = lang;
    notifyListeners();
  }

  void toggleShowValidMoves() {
    _showValidMoves = !_showValidMoves;
    notifyListeners();
  }

  bool isValidMove(int row, int col) {
    return _board.isValidMove(row, col);
  }

  /// Показать баннер "нет ходов" на 3 секунды, затем пропустить ход
  Future<void> _showSkipBannerAndSkip() async {
    _showSkipBanner = true;
    notifyListeners();
    _audio.playSkipTurn();
    await Future.delayed(const Duration(seconds: 3));
    _showSkipBanner = false;
    _board.skipTurn();
    notifyListeners();
  }

  Future<List<Cell>> makeMove(int row, int col) async {
    if (_isProcessing || !isValidMove(row, col)) {
      return [];
    }

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 100));

    List<Cell> flippedCells = _board.makeMove(row, col);

    _isProcessing = false;
    notifyListeners();

    if (flippedCells.length > 2) {
      _audio.playFlip();
    } else {
      _audio.playMove();
    }

    if (!isGameOver && validMoves.isEmpty) {
      await _showSkipBannerAndSkip();
    }

    if (isGameOver) {
      _playGameOverSound();
    }

    if (_gameMode == GameMode.vsAI &&
        currentPlayer == Player.white &&
        !isGameOver) {
      await _makeAIMove();
    }

    return flippedCells;
  }

  Future<void> _makeAIMove() async {
    if (_isProcessing || isGameOver) return;

    _isProcessing = true;
    notifyListeners();

    Cell? aiMove = await _aiPlayer.getBestMove(_board);

    if (aiMove != null) {
      _board.makeMove(aiMove.row, aiMove.col);
      notifyListeners();
      _audio.playMove();

      if (!isGameOver && validMoves.isEmpty) {
        await _showSkipBannerAndSkip();

        if (currentPlayer == Player.white && !isGameOver) {
          await _makeAIMove();
        }
      }

      if (isGameOver) {
        _playGameOverSound();
      }
    }

    _isProcessing = false;
    notifyListeners();
  }

  void skipTurn() {
    _board.skipTurn();
    notifyListeners();
  }

  void newGame({GameMode? mode}) {
    _board.reset();
    if (mode != null) _gameMode = mode;
    _isProcessing = false;
    _showSkipBanner = false;
    notifyListeners();
  }

  void _playGameOverSound() {
    final w = winner;
    if (w == Player.none) {
      _audio.playDraw();
    } else if (_gameMode == GameMode.vsAI) {
      if (w == Player.black) {
        _audio.playWin();
      } else {
        _audio.playLose();
      }
    } else {
      _audio.playWin();
    }
  }

  String getWinnerText() {
    if (!isGameOver) return '';
    final l = loc;
    final w = winner;
    if (w == Player.black) return l.blackWins;
    if (w == Player.white) return l.whiteWins;
    return l.draw;
  }
}