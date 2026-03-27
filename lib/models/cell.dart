import '../utils/constants.dart';

/// Тип модификатора клетки (активен только в режиме Хаос)
enum CellType {
  normal,    // Обычная клетка
  blocked,   // 🚫 Заблокирована — нельзя ставить фишку
  explosive, // 💥 Взрывная — переворачивает всех 8 соседей при захвате
  bonus,     // ⭐ Бонус — даёт дополнительный ход текущему игроку
}

/// Модель клетки на игровой доске
class Cell {
  final int row;
  final int col;
  Player player;
  CellType cellType;
  bool isTrapdoorFalling; // временный флаг для анимации провала

  Cell({
    required this.row,
    required this.col,
    this.player = Player.none,
    this.cellType = CellType.normal,
    this.isTrapdoorFalling = false,
  });

  bool get isEmpty => player == Player.none;

  Cell copyWith({Player? player, CellType? cellType}) {
    return Cell(
      row: row,
      col: col,
      player: player ?? this.player,
      cellType: cellType ?? this.cellType,
    );
  }

  @override
  String toString() => 'Cell($row, $col, $player, $cellType)';

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
