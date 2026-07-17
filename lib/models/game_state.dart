import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'board.dart';
import 'cell.dart';
import '../screens/game_stats.dart';
import '../utils/constants.dart';
import '../utils/ai_player.dart';
import '../utils/board_theme.dart';
import '../utils/audio_service.dart';
import '../utils/app_localizations.dart';
import '../utils/settings_service.dart';
import '../utils/achievements.dart';

/// Снимок GameState для одной отменяемой полу-хода (используется в Undo).
class _MoveSnapshot {
  final BoardSnapshot board;
  final int totalMoveCount;
  final int blackFlipped;
  final int whiteFlipped;
  final int trapdoorDrops;
  final int explosionFlips;

  const _MoveSnapshot({
    required this.board,
    required this.totalMoveCount,
    required this.blackFlipped,
    required this.whiteFlipped,
    required this.trapdoorDrops,
    required this.explosionFlips,
  });
}

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
  int _totalMoveCount = 0;
  bool _extraTurn = false;
  Cell? _lastTrapdoorCell;

  // ── Удар молнии (раз в 5 минут, сжигает случайную фишку) ─────────────────
  Timer? _lightningTimer;
  static const Duration _lightningInterval = Duration(minutes: 5);
  Cell? _lightningCell;
  Cell? get lightningCell => _lightningCell;

  // ── Статистика текущей партии ─────────────────────────────────────────────
  int _blackFlipped = 0;   // сколько фишек перевернул чёрный
  int _whiteFlipped = 0;
  int _trapdoorDrops = 0;  // фишек провалилось
  int _explosionFlips = 0; // перевёрнуто взрывами

  // Достижения, разблокированные только что сыгранной партией
  List<Achievement> _newlyUnlockedAchievements = [];
  List<Achievement> get newlyUnlockedAchievements => _newlyUnlockedAchievements;

  // Последний ход ИИ — подсвечивается на доске
  Cell? _lastAIMove;
  Cell? get lastAIMove => _lastAIMove;

  Cell? _lastMoveCell; // последний поставленный ход (для анимации веера)
  Cell? get lastMoveCell => _lastMoveCell;

  // ID партии — меняется при каждом newGame() для пересоздания CellWidget
  int _gameId = 0;
  int get gameId => _gameId;

  // Клетка взрыва — board_widget показывает партикл-анимацию
  Cell? _explosionCell;
  Cell? get explosionCell => _explosionCell;

  // Клетка сработавшего бонуса — cell_widget показывает вспышку-салют
  Cell? _bonusCell;
  Cell? get bonusCell => _bonusCell;

  // Показывать баннер о сработавшем модификаторе
  String? _modifierBannerText;
  bool get showModifierBanner => _modifierBannerText != null;
  String get modifierBannerText => _modifierBannerText ?? '';

  // Сигнал тряски доски (взрыв)
  int _shakeCount = 0;
  int get shakeCount => _shakeCount;

  void _triggerShake() {
    _shakeCount++;
    notifyListeners();
  }

  // ── История ходов (Undo) ────────────────────────────────────────────────
  final List<_MoveSnapshot> _history = [];
  static const int _maxHistory = 40;

  // ── Подсказка лучшего хода ───────────────────────────────────────────────
  Cell? _hintCell;
  Cell? get hintCell => _hintCell;
  int _hintRequestId = 0;

  GameState() {
    _board = Board();
    _boardTheme = SettingsService().boardTheme;
    _language = SettingsService().language;
    _aiPlayer = AIPlayer(difficulty: SettingsService().aiDifficulty);
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
  void setModifierMode(bool value) {
    _isModifierMode = value;
    notifyListeners();
    if (value) {
      _startLightningTimer();
    } else {
      _lightningTimer?.cancel();
      _lightningTimer = null;
    }
  }

  void _startLightningTimer() {
    _lightningTimer?.cancel();
    _lightningTimer = Timer.periodic(_lightningInterval, (_) => _triggerLightningStrike());
  }

  /// Раз в 5 минут в режиме Хаос молния случайно сжигает одну фишку на поле.
  Future<void> _triggerLightningStrike() async {
    if (!_isModifierMode || isGameOver || _isProcessing) return;

    final occupied = _board.getOccupiedNonCornerCells();
    if (occupied.isEmpty) return;

    final rng = math.Random();
    final target = occupied[rng.nextInt(occupied.length)];

    _lightningCell = target;
    _showModifierBanner(loc.modifierLightning);
    _audio.playExplosion();
    notifyListeners();

    // Молния бьёт почти мгновенно — фишка сгорает вскоре после вспышки
    await Future.delayed(const Duration(milliseconds: 260));
    target.player = Player.none;
    _triggerShake();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 950));
    _lightningCell = null;
    _modifierBannerText = null;
    notifyListeners();
  }

  void setAIDifficulty(AIDifficulty d) {
    _aiPlayer = AIPlayer(difficulty: d);
    SettingsService().setAIDifficulty(d);
    notifyListeners();
  }
  void setBoardTheme(BoardTheme t) {
    _boardTheme = t;
    SettingsService().setBoardTheme(t);
    notifyListeners();
  }
  void toggleSound() { _audio.setSoundEnabled(!_audio.soundEnabled); notifyListeners(); }
  void setLanguage(AppLanguage l) {
    _language = l;
    SettingsService().setLanguage(l);
    notifyListeners();
  }
  void toggleShowValidMoves() { _showValidMoves = !_showValidMoves; notifyListeners(); }

  bool isValidMove(int row, int col) => _board.isValidMove(row, col);

  // ── Undo ──────────────────────────────────────────────────────────────────

  /// Можно ли сейчас отменить ход
  bool get canUndo =>
      _history.isNotEmpty && !_isProcessing && !isGameOver;

  /// Можно ли сейчас показать подсказку
  bool get canHint => !_isProcessing && !isGameOver && validMoves.isNotEmpty;

  void _pushHistory() {
    _history.add(_MoveSnapshot(
      board: BoardSnapshot.capture(_board),
      totalMoveCount: _totalMoveCount,
      blackFlipped: _blackFlipped,
      whiteFlipped: _whiteFlipped,
      trapdoorDrops: _trapdoorDrops,
      explosionFlips: _explosionFlips,
    ));
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
  }

  void _applySnapshot(_MoveSnapshot snap) {
    _board.restoreSnapshot(snap.board);
    _totalMoveCount = snap.totalMoveCount;
    _blackFlipped = snap.blackFlipped;
    _whiteFlipped = snap.whiteFlipped;
    _trapdoorDrops = snap.trapdoorDrops;
    _explosionFlips = snap.explosionFlips;
    _extraTurn = false;
    _lastAIMove = null;
    _lastMoveCell = null;
    _explosionCell = null;
    _bonusCell = null;
    _lastTrapdoorCell = null;
    _modifierBannerText = null;
    _showSkipBanner = false;
    _hintCell = null;
    _hintRequestId++;
  }

  /// Отменяет последний ход. В режиме против ИИ откатывает сразу ход ИИ
  /// и предшествующий ему ход игрока — чтобы очередь снова была за игроком.
  /// В режиме "против игрока" откатывает ровно один последний ход.
  void undo() {
    if (!canUndo) return;

    _MoveSnapshot? target;
    if (_gameMode == GameMode.vsAI) {
      while (_history.isNotEmpty) {
        final snap = _history.removeLast();
        target = snap;
        if (snap.board.currentPlayer == Player.black) break;
      }
    } else {
      target = _history.removeLast();
    }

    if (target != null) {
      _applySnapshot(target);
      notifyListeners();
    }
  }

  // ── Логика хода ───────────────────────────────────────────────────────────
  Future<void> makeMove(int row, int col) async {
    if (_isProcessing || !isValidMove(row, col)) return;

    _isProcessing = true;
    _hintCell = null;
    _hintRequestId++; // отменяем отложенное скрытие предыдущей подсказки
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 100));

    _pushHistory();
    final result = _board.makeMove(row, col);
    _lastMoveCell = _board.getCell(row, col);

    // Звук
    if (result.flippedCells.length > 2 || result.explosiveFlipped.isNotEmpty) {
      _audio.playFlip();
    } else {
      _audio.playMove();
    }

    // ── Статистика переворотов ─────────────────────────────────────────────
    final flipsThisMove = result.flippedCells.length - 1; // -1 сама поставленная
    if (currentPlayer == Player.black) {
      _whiteFlipped += flipsThisMove.clamp(0, 64);
    } else {
      _blackFlipped += flipsThisMove.clamp(0, 64);
    }
    _explosionFlips += result.explosiveFlipped.length;

    // ── Обработка модификаторов ─────────────────────────────────────────────
    if (_isModifierMode && result.modifierTriggered != null) {
      await _handleModifierEffect(result, row, col);
    }

    _isProcessing = false;
    notifyListeners();

    if (_extraTurn) {
      // ── Бонусный ход: игрок, который только что сходил, получает ещё
      // один ход. board.makeMove() уже переключил игрока на соперника —
      // переключаем обратно, чтобы ходил тот же игрок.
      _extraTurn = false;
      _board.skipTurn();
      notifyListeners();

      // Важно: у игрока с доп. ходом может не оказаться доступных клеток —
      // тогда, как и при обычном ходе, нужно передать ход дальше, а не
      // оставлять игру «зависшей» без возможных ходов.
      if (!isGameOver && validMoves.isEmpty) {
        await _showSkipBannerAndSkip();
      }
    } else if (!isGameOver && validMoves.isEmpty) {
      await _showSkipBannerAndSkip();
    }

    if (isGameOver) {
      await _playGameOverSound();
      return;
    }

    // ── Хаос: проверяем провал люка и спавн новых модификаторов ────────────
    if (_isModifierMode) {
      _totalMoveCount++;
      await _checkTrapdoorEvent();
      _spawnModifiersIfNeeded();
      notifyListeners();
    }

    // На всякий случай проверяем ещё раз перед передачей хода ИИ — провал
    // люка/спавн модификаторов теоретически тоже могут оставить игрока
    // без доступных ходов.
    if (!isGameOver && validMoves.isEmpty) {
      await _showSkipBannerAndSkip();
    }

    if (isGameOver) {
      await _playGameOverSound();
      return;
    }

    // ── Ход ИИ ───────────────────────────────────────────────────────────────
    if (_gameMode == GameMode.vsAI &&
        currentPlayer == Player.white &&
        !isGameOver) {
      await _makeAIMove();
    }
  }

  Future<void> _handleModifierEffect(
      MoveResult result, int moveRow, int moveCol) async {
    switch (result.modifierTriggered) {
      case CellType.explosive:
        _explosionCell = _board.getCell(moveRow, moveCol);
        _showModifierBanner(loc.modifierExplosion);
        _audio.playExplosion();
        _triggerShake();
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 2000));
        _explosionCell = null;
        _modifierBannerText = null;
        notifyListeners();
        break;
      case CellType.bonus:
        _extraTurn = true;
        _bonusCell = _board.getCell(moveRow, moveCol);
        _showModifierBanner(loc.modifierBonus);
        _audio.playStar();
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 1800));
        _bonusCell = null;
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
    _audio.playTrapdoor();
    notifyListeners();

    // Тряска доски именно в момент, когда пол физически проваливается
    // (после фазы трещин, см. длительность анимации в CellWidget)
    await Future.delayed(const Duration(milliseconds: 650));
    _triggerShake();

    await Future.delayed(const Duration(milliseconds: 1350));

    // Убираем фишку, клетка становится обычной пустой
    target.player = Player.none;
    target.isTrapdoorFalling = false;
    target.cellType = CellType.normal;
    _lastTrapdoorCell = null;
    _modifierBannerText = null;
    _trapdoorDrops++;
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

    _hintCell = null;

    if (aiMove == null) {
      // ИИ не может ходить — пропускаем ход и передаём игроку
      _lastAIMove = null;
      _isProcessing = false;
      await _showSkipBannerAndSkip();
      notifyListeners();
      return;
    }

    // Подсвечиваем куда ходит ИИ — показываем 800ms до хода
    _lastAIMove = aiMove;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));

    _pushHistory();
    final result = _board.makeMove(aiMove.row, aiMove.col);
    _lastMoveCell = _board.getCell(aiMove.row, aiMove.col);
    notifyListeners();
    _audio.playMove();

    // ИИ попал на модификатор
    if (_isModifierMode && result.modifierTriggered != null) {
      await _handleModifierEffect(result, aiMove.row, aiMove.col);
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
      _board.skipTurn();
      notifyListeners();
      _isProcessing = false;
      await _makeAIMove();
      return;
    }

    if (isGameOver) await _playGameOverSound();

    _lastAIMove = null;
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

  /// Показывает подсказку — лучший ход для текущего игрока.
  /// Подсказка гаснет сама через несколько секунд или после следующего хода.
  void showHint() {
    if (!canHint) return;
    final move = AIPlayer().suggestBestMove(_board);
    if (move == null) return;

    _hintCell = move;
    final requestId = ++_hintRequestId;
    notifyListeners();

    Future.delayed(const Duration(seconds: 4), () {
      // Скрываем, только если за это время не появился ход/новая подсказка
      if (_hintRequestId == requestId) {
        _hintCell = null;
        notifyListeners();
      }
    });
  }

  void newGame({GameMode? mode}) {
    _board.reset();
    if (mode != null) _gameMode = mode;
    _isProcessing = false;
    _showSkipBanner = false;
    _totalMoveCount = 0;
    _extraTurn = false;
    _lastTrapdoorCell = null;
    _lastAIMove = null;
    _lastMoveCell = null;
    _explosionCell = null;
    _bonusCell = null;
    _modifierBannerText = null;
    _blackFlipped = 0;
    _whiteFlipped = 0;
    _trapdoorDrops = 0;
    _explosionFlips = 0;
    _history.clear();
    _hintCell = null;
    _hintRequestId++;
    _newlyUnlockedAchievements = [];
    _gameId++; // ← пересоздаём все CellWidget
    notifyListeners();
  }

  Future<void> _playGameOverSound() async {
    final w = winner;
    if (w == Player.none) {
      _audio.playDraw();
    } else if (_gameMode == GameMode.vsAI) {
      if (w == Player.black) {
        _isModifierMode ? _audio.playFirework() : _audio.playWin();
      } else {
        _audio.playLose();
      }
    } else {
      _isModifierMode ? _audio.playFirework() : _audio.playWin();
    }
    await _saveRecord();
  }

  Future<void> _saveRecord() async {
    final w = winner;
    final beforeRecords = List<GameRecord>.from(StatsRepository().records);

    await StatsRepository().add(GameRecord(
      dateTime: DateTime.now(),
      mode: _isModifierMode ? 'chaos' : 'classic',
      opponent: _gameMode == GameMode.vsAI ? 'ai' : 'player',
      blackScore: blackScore,
      whiteScore: whiteScore,
      winner: w == Player.black
          ? 'black'
          : w == Player.white
          ? 'white'
          : 'draw',
      totalMoves: _totalMoveCount,
      blackFlipped: _blackFlipped,
      whiteFlipped: _whiteFlipped,
      trapdoorDrops: _trapdoorDrops,
      explosionFlips: _explosionFlips,
      difficulty: _gameMode == GameMode.vsAI ? _aiPlayer.difficulty.name : null,
    ));

    _newlyUnlockedAchievements = Achievements.newlyUnlocked(
      beforeRecords,
      StatsRepository().records,
    );
    if (_newlyUnlockedAchievements.isNotEmpty) {
      notifyListeners();
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

  @override
  void dispose() {
    _lightningTimer?.cancel();
    super.dispose();
  }
}