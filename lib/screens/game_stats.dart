import 'dart:convert';

/// Запись одной сыгранной партии
class GameRecord {
  final DateTime dateTime;
  final String mode;        // 'classic' | 'chaos'
  final String opponent;    // 'player' | 'ai'
  final int blackScore;
  final int whiteScore;
  final String winner;      // 'black' | 'white' | 'draw'
  final int totalMoves;
  final int blackFlipped;   // сколько фишек перевернул чёрный
  final int whiteFlipped;
  final int trapdoorDrops;  // упало в дыру (chaos)
  final int explosionFlips; // перевёрнуто взрывами (chaos)

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
  );
}

/// Хранилище всех партий (in-memory + JSON сериализация)
class StatsRepository {
  static final StatsRepository _instance = StatsRepository._();
  factory StatsRepository() => _instance;
  StatsRepository._();

  final List<GameRecord> _records = [];

  List<GameRecord> get records => List.unmodifiable(_records);
  List<GameRecord> get classicRecords =>
      _records.where((r) => r.mode == 'classic').toList();
  List<GameRecord> get chaosRecords =>
      _records.where((r) => r.mode == 'chaos').toList();

  void add(GameRecord record) => _records.insert(0, record); // новые первыми

  void clear() => _records.clear();

  // Сводная статистика
  int get totalGames => _records.length;
  int get totalWins =>
      _records.where((r) => r.winner == 'black').length;
  int get totalMoves =>
      _records.fold(0, (sum, r) => sum + r.totalMoves);

  String toJson() => jsonEncode(_records.map((r) => r.toJson()).toList());

  void fromJson(String raw) {
    try {
      final list = jsonDecode(raw) as List;
      _records
        ..clear()
        ..addAll(list.map((e) => GameRecord.fromJson(e as Map<String, dynamic>)));
    } catch (_) {}
  }
}