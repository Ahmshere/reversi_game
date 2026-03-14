import 'cell.dart';
import '../utils/constants.dart';

/// Класс игровой доски с логикой Reversi
class Board {
  late List<List<Cell>> cells;
  Player currentPlayer = Player.black;

  Board() {
    _initializeBoard();
  }

  /// Инициализация доски - создание начальной позиции
  void _initializeBoard() {
    cells = List.generate(
      GameConstants.boardSize,
      (row) => List.generate(
        GameConstants.boardSize,
        (col) => Cell(row: row, col: col),
      ),
    );

    // Начальная позиция (4 фишки в центре)
    final center = GameConstants.boardSize ~/ 2;
    cells[center - 1][center - 1].player = Player.white;
    cells[center - 1][center].player = Player.black;
    cells[center][center - 1].player = Player.black;
    cells[center][center].player = Player.white;
  }

  /// Получить клетку по координатам
  Cell getCell(int row, int col) {
    return cells[row][col];
  }

  /// Проверка валидности хода
  bool isValidMove(int row, int col) {
    if (!_isInBounds(row, col) || !cells[row][col].isEmpty) {
      return false;
    }

    return _getFlippedCells(row, col, currentPlayer).isNotEmpty;
  }

  /// Получить список всех валидных ходов для текущего игрока
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

  /// Сделать ход
  List<Cell> makeMove(int row, int col) {
    if (!isValidMove(row, col)) {
      return [];
    }

    // Получаем клетки для переворота
    List<Cell> cellsToFlip = _getFlippedCells(row, col, currentPlayer);

    // Ставим фишку
    cells[row][col].player = currentPlayer;

    // Переворачиваем захваченные фишки
    for (Cell cell in cellsToFlip) {
      cells[cell.row][cell.col].player = currentPlayer;
    }

    // Добавляем поставленную фишку в список перевернутых (для анимации)
    cellsToFlip.add(cells[row][col]);

    // Переключаем игрока
    _switchPlayer();

    return cellsToFlip;
  }

  /// Получить клетки, которые будут перевернуты при ходе
  List<Cell> _getFlippedCells(int row, int col, Player player) {
    List<Cell> flippedCells = [];

    // 8 направлений: вверх, вниз, влево, вправо и 4 диагонали
    final directions = [
      [-1, 0], // вверх
      [1, 0], // вниз
      [0, -1], // влево
      [0, 1], // вправо
      [-1, -1], // вверх-влево
      [-1, 1], // вверх-вправо
      [1, -1], // вниз-влево
      [1, 1], // вниз-вправо
    ];

    for (var dir in directions) {
      List<Cell> cellsInDirection = _checkDirection(row, col, dir[0], dir[1], player);
      flippedCells.addAll(cellsInDirection);
    }

    return flippedCells;
  }

  /// Проверка в одном направлении
  List<Cell> _checkDirection(int row, int col, int dRow, int dCol, Player player) {
    List<Cell> cellsToFlip = [];
    int currentRow = row + dRow;
    int currentCol = col + dCol;
    Player opponent = _getOpponent(player);

    // Идем в направлении, пока не найдем край доски или пустую клетку
    while (_isInBounds(currentRow, currentCol)) {
      Cell currentCell = cells[currentRow][currentCol];

      if (currentCell.isEmpty) {
        // Пустая клетка - не можем захватить
        return [];
      } else if (currentCell.player == opponent) {
        // Фишка противника - добавляем в список
        cellsToFlip.add(currentCell);
      } else {
        // Наша фишка - возвращаем все клетки между
        return cellsToFlip;
      }

      currentRow += dRow;
      currentCol += dCol;
    }

    // Достигли края доски - не можем захватить
    return [];
  }

  /// Проверка, находится ли координата в пределах доски
  bool _isInBounds(int row, int col) {
    return row >= 0 &&
        row < GameConstants.boardSize &&
        col >= 0 &&
        col < GameConstants.boardSize;
  }

  /// Получить противника
  Player _getOpponent(Player player) {
    return player == Player.black ? Player.white : Player.black;
  }

  /// Переключить игрока
  void _switchPlayer() {
    currentPlayer = _getOpponent(currentPlayer);
  }

  /// Подсчет фишек для игрока
  int countPieces(Player player) {
    int count = 0;
    for (var row in cells) {
      for (var cell in row) {
        if (cell.player == player) {
          count++;
        }
      }
    }
    return count;
  }

  /// Проверка окончания игры
  bool isGameOver() {
    // Игра окончена, если нет валидных ходов для обоих игроков
    if (getValidMoves().isNotEmpty) {
      return false;
    }

    // Проверяем валидные ходы для противника
    Player original = currentPlayer;
    _switchPlayer();
    bool opponentHasMoves = getValidMoves().isNotEmpty;
    currentPlayer = original;

    return !opponentHasMoves;
  }

  /// Получить победителя (или null если ничья)
  Player? getWinner() {
    if (!isGameOver()) {
      return null;
    }

    int blackCount = countPieces(Player.black);
    int whiteCount = countPieces(Player.white);

    if (blackCount > whiteCount) {
      return Player.black;
    } else if (whiteCount > blackCount) {
      return Player.white;
    } else {
      return Player.none; // Ничья
    }
  }

  /// Пропустить ход (если нет валидных ходов)
  void skipTurn() {
    _switchPlayer();
  }

  /// Сброс игры
  void reset() {
    _initializeBoard();
    currentPlayer = Player.black;
  }
}
