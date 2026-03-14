import 'package:flutter/material.dart';

/// Константы для игры Reversi
class GameConstants {
  // Размеры доски
  static const int boardSize = 8; // 8x8 клеток
  
  // Цвета игроков
  static const Color blackPlayerColor = Color(0xFF2C3E50);
  static const Color whitePlayerColor = Color(0xFFECF0F1);
  
  // Цвета UI
  static const Color boardColor = Color(0xFF27AE60);
  static const Color gridLineColor = Color(0xFF1E8449);
  static const Color validMoveColor = Color(0x8034495E);
  static const Color backgroundColor = Color(0xFF1A1A2E);
  
  // Градиенты для фишек
  static const List<Color> blackGradient = [
    Color(0xFF2C3E50),
    Color(0xFF34495E),
  ];
  
  static const List<Color> whiteGradient = [
    Color(0xFFECF0F1),
    Color(0xFFBDC3C7),
  ];
  
  // Размеры и отступы
  static const double cellPadding = 2.0;
  static const double pieceScale = 0.85;
  static const double borderRadius = 4.0;
  
  // Анимации
  static const Duration flipDuration = Duration(milliseconds: 300);
  static const Duration placeDuration = Duration(milliseconds: 200);
  
  // Текстовые стили
  static const TextStyle titleStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle scoreStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static const TextStyle buttonStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}

/// Перечисление для игроков
enum Player {
  black,
  white,
  none, // Пустая клетка
}
