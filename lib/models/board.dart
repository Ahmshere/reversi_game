import 'cell.dart';
import '../utils/constants.dart';

/// Результат хода — содержит перевёрнутые клетки и сработавший модификатор
class MoveResult {
  final List<Cell> flippedCells;
  final CellType? modifierTriggered;
  final List<Cell> explosiveFlipped; // дополнительно перевёрнутые взрывом

  const MoveResult({
    required this.flippedCells,
    this.modifierTriggered,
    this.explosiveFlipped = const [],
  });
}

/// Класс игровой доски с логикой Reversi
class Board {
  late List<List<Cell>> cells;
  Player currentPlayer = Player.black;

  Board() {
    _initializeBoard();
  }

  void _initializeBoard() {
    cells = List.generate(
      GameConstants.boardSize,
      (row) => List.generate(
        GameConstants.boardSize,
        (col) => Cell(row: row, col: col),
      ),
    );

    final center = GameConstants.boardSize ~/ 2;
    cells[center - 1][center - 1].player = Player.white;
    cells[center - 1][center].player = Player.black;
    cells[center][center - 1].player = Player.black;
    cells[center][center].player = Player.white;
  }

  Cell getCell(int row, int col) => cells[row][col];

  /// Проверка валидности хода (учитывает заблокированные клетки)
  bool isValidMove(int row, int col) {
    if (!_isInBounds(row, col)) return false;
    final cell = cells[row][col];
    if (!cell.isEmpty) return false;
    if (cell.cellType == CellType.blocked) return false;
    return _getFlippedCells(row, col, currentPlayer).isNotEmpty;
  }

  List<Cell> getValidMoves() {
    List<Cell> validMoves = [];
    for (int row = 0; row < GameConstants.boardSize; row++) {
      for (int col = 0; col < GameConstants.boardSize; col++) {
        if (isValidMove(row, col)) {
          validMoves.add(cells[row][col]);
        }
      }
    }
    return validMoves;
  }

  /// Сделать ход — возвращает MoveResult с информацией о сработавших модификаторах
  MoveResult makeMove(int row, int col) {
    if (!isValidMove(row, col)) {
      return const MoveResult(flippedCells: []);
    }

    List<Cell> cellsToFlip = _getFlippedCells(row, col, currentPlayer);
    final triggeredModifier = cells[row][col].cellType;

    // Ставим фишку, сбрасываем модификатор клетки
    cells[row][col].player = currentPlayer;
    cells[row][col].cellType = CellType.normal;

    // Переворачиваем захваченные фишки
    for (Cell cell in cellsToFlip) {
      cells[cell.row][cell.col].player = currentPlayer;
    }
    cellsToFlip.add(cells[row][col]);

    // ── Обработка модификаторов ──────────────────────────────────────────────
    List<Cell> explosiveFlipped = [];

    if (triggeredModifier == CellType.explosive) {
      // Взрыв: переворачиваем всех 8 соседей у которых есть фишки
      for (final dir in _directions) {
        final nr = row + dir[0];
        final nc = col + dir[1];
        if (_isInBounds(nr, nc) &&
            !cells[nr][nc].isEmpty &&
            cells[nr][nc].cellType != CellType.blocked) {
          cells[nr][nc].player = currentPlayer;
          explosiveFlipped.add(cells[nr][nc]);
        }
      }
    }

    // Trapdoor: если фишка поставлена на клетку с люком — она исчезает
    // (обрабатывается в GameState через triggerTrapdoorEvent)

    // Бонус и заблокированные обрабатываются в GameState

    _switchPlayer();

    return MoveResult(
      flippedCells: cellsToFlip,
      modifierTriggered: triggeredModifier == CellType.normal
          ? null
          : triggeredModifier,
      explosiveFlipped: explosiveFlipped,
    );
  }

  // ── Helpers для режима Хаос ──────────────────────────────────────────────

  /// Установить модификатор на клетку
  void setModifier(int row, int col, CellType type) {
    cells[row][col].cellType = type;
  }

  /// Пустые клетки, не являющиеся углами
  List<Cell> getEmptyNonCornerCells() {
    final result = <Cell>[];
    for (int r = 0; r < GameConstants.boardSize; r++) {
      for (int c = 0; c < GameConstants.boardSize; c++) {
        if (cells[r][c].isEmpty &&
            cells[r][c].cellType == CellType.normal &&
            !_isCorner(r, c)) {
          result.add(cells[r][c]);
        }
      }
    }
    return result;
  }

  /// Занятые клетки, не являющиеся углами
  List<Cell> getOccupiedNonCornerCells() {
    final result = <Cell>[];
    for (int r = 0; r < GameConstants.boardSize; r++) {
      for (int c = 0; c < GameConstants.boardSize; c++) {
        if (!cells[r][c].isEmpty &&
            cells[r][c].cellType == CellType.normal &&
            !_isCorner(r, c)) {
          result.add(cells[r][c]);
        }
      }
    }
    return result;
  }

  /// Количество активных модификаторов на доске
  int get activeModifiersCount {
    int count = 0;
    for (int r = 0; r < GameConstants.boardSize; r++) {
      for (int c = 0; c < GameConstants.boardSize; c++) {
        if (cells[r][c].cellType != CellType.normal) count++;
      }
    }
    return count;
  }

  // ── Приватные методы ─────────────────────────────────────────────────────

  List<Cell> _getFlippedCells(int row, int col, Player player) {
    List<Cell> flippedCells = [];
    for (var dir in _directions) {
      flippedCells.addAll(_checkDirection(row, col, dir[0], dir[1], player));
    }
    return flippedCells;
  }

  List<Cell> _checkDirection(
      int row, int col, int dRow, int dCol, Player player) {
    List<Cell> cellsToFlip = [];
    int currentRow = row + dRow;
    int currentCol = col + dCol;
    Player opponent = _getOpponent(player);

    while (_isInBounds(currentRow, currentCol)) {
      Cell currentCell = cells[currentRow][currentCol];

      // Пустые или заблокированные клетки — нельзя захватить через них
      if (currentCell.isEmpty || currentCell.cellType == CellType.blocked) {
        return [];
      } else if (currentCell.player == opponent) {
        cellsToFlip.add(currentCell);
      } else {
        return cellsToFlip;
      }

      currentRow += dRow;
      currentCol += dCol;
    }
    return [];
  }

  bool _isInBounds(int row, int col) =>
      row >= 0 &&
      row < GameConstants.boardSize &&
      col >= 0 &&
      col < GameConstants.boardSize;

  bool _isCorner(int row, int col) {
    final s = GameConstants.boardSize - 1;
    return (row == 0 || row == s) && (col == 0 || col == s);
  }

  Player _getOpponent(Player player) =>
      player == Player.black ? Player.white : Player.black;

  void _switchPlayer() {
    currentPlayer = _getOpponent(currentPlayer);
  }

  int countPieces(Player player) {
    int count = 0;
    for (var row in cells) {
      for (var cell in row) {
        if (cell.player == player) count++;
      }
    }
    return count;
  }

  bool isGameOver() {
    if (getValidMoves().isNotEmpty) return false;
    Player original = currentPlayer;
    _switchPlayer();
    bool opponentHasMoves = getValidMoves().isNotEmpty;
    currentPlayer = original;
    return !opponentHasMoves;
  }

  Player? getWinner() {
    if (!isGameOver()) return null;
    int blackCount = countPieces(Player.black);
    int whiteCount = countPieces(Player.white);
    if (blackCount > whiteCount) return Player.black;
    if (whiteCount > blackCount) return Player.white;
    return Player.none;
  }

  void skipTurn() => _switchPlayer();

  void reset() {
    _initializeBoard();
    currentPlayer = Player.black;
  }

  static const List<List<int>> _directions = [
    [-1, 0], [1, 0], [0, -1], [0, 1],
    [-1, -1], [-1, 1], [1, -1], [1, 1],
  ];
}
