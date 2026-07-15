import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Запись одной сыгранной партии
class GameRecord {
  final DateTime dateTime;
  final String mode;        // 'classic' | 'chaos'
  final String opponent;    // 'player' | 'ai'
  final int blackScore;
  final int whiteScore;
  final String winner;      // 'black' | 'white' | 'draw'
  final int totalMoves;
  final int blackFlipped;
  final int whiteFlipped;
  final int trapdoorDrops;
  final int explosionFlips;
  final String? difficulty; // 'easy' | 'medium' | 'hard' | null (если opponent == 'player')

  const GameRecord({
    required this.dateTime,
    required this.mode,
    required this.opponent,
    required this.blackScore,
    required this.whiteScore,
    required this.winner,
    required this.totalMoves,
    required this.blackFlipped,
    required this.whiteFlipped,
    this.trapdoorDrops = 0,
    this.explosionFlips = 0,
    this.difficulty,
  });

  Map<String, dynamic> toJson() => {
    'dateTime': dateTime.toIso8601String(),
    'mode': mode,
    'opponent': opponent,
    'blackScore': blackScore,
    'whiteScore': whiteScore,
    'winner': winner,
    'totalMoves': totalMoves,
    'blackFlipped': blackFlipped,
    'whiteFlipped': whiteFlipped,
    'trapdoorDrops': trapdoorDrops,
    'explosionFlips': explosionFlips,
    'difficulty': difficulty,
  };

  factory GameRecord.fromJson(Map<String, dynamic> j) => GameRecord(
    dateTime: DateTime.parse(j['dateTime'] as String),
    mode: j['mode'] as String,
    opponent: j['opponent'] as String,
    blackScore: j['blackScore'] as int,
    whiteScore: j['whiteScore'] as int,
    winner: j['winner'] as String,
    totalMoves: j['totalMoves'] as int,
    blackFlipped: j['blackFlipped'] as int,
    whiteFlipped: j['whiteFlipped'] as int,
    trapdoorDrops: (j['trapdoorDrops'] as int?) ?? 0,
    explosionFlips: (j['explosionFlips'] as int?) ?? 0,
    difficulty: j['difficulty'] as String?,
  );
}

/// Хранилище всех партий — сохраняется в SharedPreferences
class StatsRepository {
  static final StatsRepository _instance = StatsRepository._();
  factory StatsRepository() => _instance;
  StatsRepository._();

  static const _kStatsKey = 'reversi_game_stats';

  final List<GameRecord> _records = [];
  bool _loaded = false;

  // ── Загрузка при первом обращении ─────────────────────────────────────────

  /// Вызвать один раз при старте приложения (в main.dart)
  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStatsKey);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List;
        _records
          ..clear()
          ..addAll(
            list.map((e) => GameRecord.fromJson(e as Map<String, dynamic>)),
          );
      }
    } catch (_) {
      // Если данные повреждены — начинаем с чистого листа
    }
    _loaded = true;
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kStatsKey,
        jsonEncode(_records.map((r) => r.toJson()).toList()),
      );
    } catch (_) {}
  }

  // ── Публичный API ─────────────────────────────────────────────────────────

  List<GameRecord> get records => List.unmodifiable(_records);
  List<GameRecord> get classicRecords =>
      _records.where((r) => r.mode == 'classic').toList();
  List<GameRecord> get chaosRecords =>
      _records.where((r) => r.mode == 'chaos').toList();

  Future<void> add(GameRecord record) async {
    _records.insert(0, record); // новые первыми
    await _save();
  }

  Future<void> clear() async {
    _records.clear();
    await _save();
  }

  // Сводная статистика
  int get totalGames => _records.length;
  int get totalWins => _records.where((r) => r.winner == 'black').length;
  int get totalMoves => _records.fold(0, (sum, r) => sum + r.totalMoves);

  // Оставляем для обратной совместимости
  String toJson() => jsonEncode(_records.map((r) => r.toJson()).toList());

  void fromJson(String raw) {
    try {
      final list = jsonDecode(raw) as List;
      _records
        ..clear()
        ..addAll(
          list.map((e) => GameRecord.fromJson(e as Map<String, dynamic>)),
        );
    } catch (_) {}
  }
}