import 'package:flutter/material.dart';

/// Темы для игровой доски
enum BoardTheme {
  classic,
  ocean,
  sunset,
  forest,
  night,
  royal,
}

/// Класс с настройками темы доски
class BoardThemeData {
  final Color boardColor;
  final Color gridLineColor;
  final String name;

  const BoardThemeData({
    required this.boardColor,
    required this.gridLineColor,
    required this.name,
  });

  static const Map<BoardTheme, BoardThemeData> themes = {
    BoardTheme.classic: BoardThemeData(
      boardColor: Color(0xFF65CC8E),
      gridLineColor: Color(0xFF1E8449),
      name: 'Classic Green',
    ),
    BoardTheme.ocean: BoardThemeData(
      boardColor: Color(0xFF3498DB),
      gridLineColor: Color(0xFF2980B9),
      name: 'Ocean Blue',
    ),
    BoardTheme.sunset: BoardThemeData(
      boardColor: Color(0xFFE67E22),
      gridLineColor: Color(0xFFD35400),
      name: 'Sunset Orange',
    ),
    BoardTheme.forest: BoardThemeData(
      boardColor: Color(0xFF6EDCC3),
      gridLineColor: Color(0xFF138D75),
      name: 'Forest Teal',
    ),
    BoardTheme.night: BoardThemeData(
      boardColor: Color(0xFF34495E),
      gridLineColor: Color(0xFF2C3E50),
      name: 'Night Gray',
    ),
    BoardTheme.royal: BoardThemeData(
      boardColor: Color(0xFF8E44AD),
      gridLineColor: Color(0xFF6C3483),
      name: 'Royal Purple',
    ),
  };

  static BoardThemeData getTheme(BoardTheme theme) {
    return themes[theme]!;
  }
}