import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'board.dart';
import 'cell.dart';
import '../utils/constants.dart';
import '../utils/ai_player.dart';
import '../utils/board_theme.dart';
import '../utils/audio_service.dart';
import '../utils/app_localizations.dart';

enum GameMode { vsPlayer, vsAI }

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

  // ── Режим Хаос ────────────────────────────────────────────────────────────
  bool _isModifierMode = false;
  int _totalMoveCount = 0; // суммарно ходов в текущей игре (оба игрока)
  bool _extraTurn = false; // бонусная клетка: текущий игрок ходит ещё раз
  Cell? _lastTrapdoorCell; // клетка, которая сейчас "проваливается"

  // Показывать баннер о сработавшем модификаторе
  String? _modifierBannerText;
  bool get showModifierBanner => _modifierBannerText != null;
  String get modifierBannerText => _modifierBannerText ?? '';

  GameState() {
    _board = Board();
    _aiPlayer = AIPlayer(difficulty: AIDifficulty.medium);
  }

  // ── Геттеры ───────────────────────────────────────────────────────────────
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
  bool get isModifierMode => _isModifierMode;
  int get totalMoveCount => _totalMoveCount;
  Cell? get lastTrapdoorCell => _lastTrapdoorCell;

  int get blackScore => _board.countPieces(Player.black);
  int get whiteScore => _board.countPieces(Player.white);
  bool get isGameOver => _board.isGameOver();
  Player? get winner => _board.getWinner();
  List<Cell> get validMoves => _board.getValidMoves();

  // ── Сеттеры ───────────────────────────────────────────────────────────────
  void setGameMode(GameMode mode) { _gameMode = mode; notifyListeners(); }
  void setModifierMode(bool value) { _isModifierMode = value; notifyListeners(); }
  void setAIDifficulty(AIDifficulty d) { _aiPlayer = AIPlayer(difficulty: d); notifyListeners(); }
  void setBoardTheme(BoardTheme t) { _boardTheme = t; notifyListeners(); }
  void toggleSound() { _audio.setSoundEnabled(!_audio.soundEnabled); notifyListeners(); }
  void setLanguage(AppLanguage l) { _language = l; notifyListeners(); }
  void toggleShowValidMoves() { _showValidMoves = !_showValidMoves; notifyListeners(); }

  bool isValidMove(int row, int col) => _board.isValidMove(row, col);

  // ── Логика хода ───────────────────────────────────────────────────────────
  Future<void> makeMove(int row, int col) async {
    if (_isProcessing || !isValidMove(row, col)) return;

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 100));

    final result = _board.makeMove(row, col);

    // Звук
    if (result.flippedCells.length > 2 || result.explosiveFlipped.isNotEmpty) {
      _audio.playFlip();
    } else {
      _audio.playMove();
    }

    // ── Обработка модификаторов ─────────────────────────────────────────────
    if (_isModifierMode && result.modifierTriggered != null) {
      await _handleModifierEffect(result);
    }

    _isProcessing = false;
    notifyListeners();

    if (!isGameOver && validMoves.isEmpty) {
      await _showSkipBannerAndSkip();
    }

    if (isGameOver) {
      _playGameOverSound();
      return;
    }

    // ── Хаос: проверяем провал люка и спавн новых модификаторов ────────────
    if (_isModifierMode) {
      _totalMoveCount++;
      await _checkTrapdoorEvent();
      _spawnModifiersIfNeeded();
      notifyListeners();
    }

    // ── Бонусный ход: текущий игрок ходит снова ─────────────────────────────
    if (_extraTurn) {
      _extraTurn = false;
      // board уже переключил игрока → переключаем обратно
      _board.skipTurn();
      notifyListeners();
      return; // ход остаётся за тем же игроком, AI не вызываем
    }

    // ── Ход ИИ ───────────────────────────────────────────────────────────────
    if (_gameMode == GameMode.vsAI &&
        currentPlayer == Player.white &&
        !isGameOver) {
      await _makeAIMove();
    }
  }

  Future<void> _handleModifierEffect(MoveResult result) async {
    switch (result.modifierTriggered) {
      case CellType.explosive:
        _showModifierBanner(loc.modifierExplosion);
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 1200));
        _modifierBannerText = null;
        notifyListeners();
        break;
      case CellType.bonus:
        _extraTurn = true;
        _showModifierBanner(loc.modifierBonus);
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 1000));
        _modifierBannerText = null;
        notifyListeners();
        break;
      default:
        break;
    }
  }

  void _showModifierBanner(String text) {
    _modifierBannerText = text;
  }

  // ── Провал люка ──────────────────────────────────────────────────────────
  Future<void> _checkTrapdoorEvent() async {
    final m = _totalMoveCount;
    // Срабатывает на ходах 5, 7, 15, 17, 25, 27 ...
    if (m % 10 == 5 || m % 10 == 7) {
      await _triggerTrapdoorEvent();
    }
  }

  Future<void> _triggerTrapdoorEvent() async {
    final rng = math.Random();
    final occupied = _board.getOccupiedNonCornerCells();
    if (occupied.isEmpty) return;

    final target = occupied[rng.nextInt(occupied.length)];

    // Анимация: показываем что клетка "падает"
    _lastTrapdoorCell = target;
    target.isTrapdoorFalling = true;
    _showModifierBanner(loc.modifierTrapdoor);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));

    // Убираем фишку, клетка становится обычной пустой
    target.player = Player.none;
    target.isTrapdoorFalling = false;
    target.cellType = CellType.normal;
    _lastTrapdoorCell = null;
    _modifierBannerText = null;
    notifyListeners();
  }

  // ── Спавн модификаторов ──────────────────────────────────────────────────
  void _spawnModifiersIfNeeded() {
    // Начинаем с хода 4, затем каждые 6 ходов
    if (_totalMoveCount < 4) return;
    if ((_totalMoveCount - 4) % 6 != 0) return;
    if (_board.activeModifiersCount >= 5) return;

    final rng = math.Random();
    final empty = _board.getEmptyNonCornerCells();
    if (empty.isEmpty) return;

    empty.shuffle(rng);
    final spawnCount = math.min(2, empty.length);

    for (int i = 0; i < spawnCount; i++) {
      final cell = empty[i];
      final roll = rng.nextDouble();
      CellType type;
      if (roll < 0.40) {
        type = CellType.blocked;
      } else if (roll < 0.75) {
        type = CellType.explosive;
      } else {
        type = CellType.bonus;
      }
      _board.setModifier(cell.row, cell.col, type);
    }
  }

  // ── Ход ИИ ───────────────────────────────────────────────────────────────
  Future<void> _makeAIMove() async {
    if (_isProcessing || isGameOver) return;

    _isProcessing = true;
    notifyListeners();

    Cell? aiMove = await _aiPlayer.getBestMove(_board);

    if (aiMove != null) {
      final result = _board.makeMove(aiMove.row, aiMove.col);
      notifyListeners();
      _audio.playMove();

      // ИИ попал на модификатор
      if (_isModifierMode && result.modifierTriggered != null) {
        await _handleModifierEffect(result);
      }

      if (_isModifierMode) {
        _totalMoveCount++;
        await _checkTrapdoorEvent();
        _spawnModifiersIfNeeded();
        notifyListeners();
      }

      if (!isGameOver && validMoves.isEmpty) {
        await _showSkipBannerAndSkip();
        if (currentPlayer == Player.white && !isGameOver) {
          _isProcessing = false;
          await _makeAIMove();
          return;
        }
      }

      // Бонус для ИИ: он ходит ещё раз
      if (_extraTurn) {
        _extraTurn = false;
        _board.skipTurn(); // вернуть ход ИИ (белому)
        notifyListeners();
        _isProcessing = false;
        await _makeAIMove();
        return;
      }

      if (isGameOver) _playGameOverSound();
    }

    _isProcessing = false;
    notifyListeners();
  }

  // ── Вспомогательное ──────────────────────────────────────────────────────
  Future<void> _showSkipBannerAndSkip() async {
    _showSkipBanner = true;
    notifyListeners();
    _audio.playSkipTurn();
    await Future.delayed(const Duration(seconds: 3));
    _showSkipBanner = false;
    _board.skipTurn();
    notifyListeners();
  }

  void skipTurn() { _board.skipTurn(); notifyListeners(); }

  void newGame({GameMode? mode}) {
    _board.reset();
    if (mode != null) _gameMode = mode;
    _isProcessing = false;
    _showSkipBanner = false;
    _totalMoveCount = 0;
    _extraTurn = false;
    _lastTrapdoorCell = null;
    _modifierBannerText = null;
    notifyListeners();
  }

  void _playGameOverSound() {
    final w = winner;
    if (w == Player.none) {
      _audio.playDraw();
    } else if (_gameMode == GameMode.vsAI) {
      if (w == Player.black) _audio.playWin(); else _audio.playLose();
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