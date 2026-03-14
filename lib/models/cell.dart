import '../utils/constants.dart';

/// Модель клетки на игровой доске
class Cell {
  final int row;
  final int col;
  Player player;

  Cell({
    required this.row,
    required this.col,
    this.player = Player.none,
  });

  /// Проверка, пустая ли клетка
  bool get isEmpty => player == Player.none;

  /// Копирование клетки с возможностью изменения игрока
  Cell copyWith({Player? player}) {
    return Cell(
      row: row,
      col: col,
      player: player ?? this.player,
    );
  }

  @override
  String toString() => 'Cell($row, $col, $player)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cell &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col &&
          player == other.player;

  @override
  int get hashCode => row.hashCode ^ col.hashCode ^ player.hashCode;
}
