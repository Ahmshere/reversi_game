import '../screens/game_stats.dart';
import 'app_localizations.dart';

/// Одно достижение — условие разблокировки проверяется по всей истории партий.
class Achievement {
  final String id;
  final String emoji;
  final String Function(AppLocalizations l) title;
  final String Function(AppLocalizations l) description;
  final bool Function(List<GameRecord> records) isUnlocked;

  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });
}

/// Реестр всех достижений игры + вспомогательные функции.
class Achievements {
  Achievements._();

  static bool _isWin(GameRecord r) => r.winner == 'black';

  /// Лучшая серия побед подряд за всю историю (не только текущая).
  static int _bestStreak(List<GameRecord> records) {
    // records хранятся от новых к старым — переворачиваем в хронологический порядок.
    final chronological = records.reversed.toList();
    int best = 0;
    int current = 0;
    for (final r in chronological) {
      if (_isWin(r)) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }

  static final List<Achievement> all = [
    Achievement(
      id: 'first_game',
      emoji: '🎮',
      title: (l) => l.achFirstGameTitle,
      description: (l) => l.achFirstGameDesc,
      isUnlocked: (r) => r.isNotEmpty,
    ),
    Achievement(
      id: 'games_10',
      emoji: '🎯',
      title: (l) => l.achGames10Title,
      description: (l) => l.achGames10Desc,
      isUnlocked: (r) => r.length >= 10,
    ),
    Achievement(
      id: 'games_50',
      emoji: '🏅',
      title: (l) => l.achGames50Title,
      description: (l) => l.achGames50Desc,
      isUnlocked: (r) => r.length >= 50,
    ),
    Achievement(
      id: 'first_win',
      emoji: '🏆',
      title: (l) => l.achFirstWinTitle,
      description: (l) => l.achFirstWinDesc,
      isUnlocked: (r) => r.any(_isWin),
    ),
    Achievement(
      id: 'streak_3',
      emoji: '🔥',
      title: (l) => l.achStreak3Title,
      description: (l) => l.achStreak3Desc,
      isUnlocked: (r) => _bestStreak(r) >= 3,
    ),
    Achievement(
      id: 'streak_5',
      emoji: '💪',
      title: (l) => l.achStreak5Title,
      description: (l) => l.achStreak5Desc,
      isUnlocked: (r) => _bestStreak(r) >= 5,
    ),
    Achievement(
      id: 'domination',
      emoji: '💯',
      title: (l) => l.achDominationTitle,
      description: (l) => l.achDominationDesc,
      isUnlocked: (r) =>
          r.any((g) => _isWin(g) && (g.blackScore - g.whiteScore) >= 40),
    ),
    Achievement(
      id: 'speedrun',
      emoji: '⚡',
      title: (l) => l.achSpeedrunTitle,
      description: (l) => l.achSpeedrunDesc,
      isUnlocked: (r) =>
          r.any((g) => _isWin(g) && g.totalMoves > 0 && g.totalMoves <= 22),
    ),
    Achievement(
      id: 'boom',
      emoji: '💥',
      title: (l) => l.achBoomTitle,
      description: (l) => l.achBoomDesc,
      isUnlocked: (r) => r.any((g) => g.explosionFlips > 0),
    ),
    Achievement(
      id: 'chain_reaction',
      emoji: '🎆',
      title: (l) => l.achChainReactionTitle,
      description: (l) => l.achChainReactionDesc,
      isUnlocked: (r) => r.any((g) => g.explosionFlips >= 15),
    ),
    Achievement(
      id: 'trapdoor',
      emoji: '🕳️',
      title: (l) => l.achTrapdoorTitle,
      description: (l) => l.achTrapdoorDesc,
      isUnlocked: (r) => r.any((g) => g.trapdoorDrops > 0),
    ),
    Achievement(
      id: 'chaos_master',
      emoji: '🌀',
      title: (l) => l.achChaosMasterTitle,
      description: (l) => l.achChaosMasterDesc,
      isUnlocked: (r) =>
          r.where((g) => g.mode == 'chaos' && _isWin(g)).length >= 10,
    ),
    Achievement(
      id: 'giant_slayer',
      emoji: '🥋',
      title: (l) => l.achGiantSlayerTitle,
      description: (l) => l.achGiantSlayerDesc,
      isUnlocked: (r) => r.any(
            (g) => g.opponent == 'ai' && g.difficulty == 'hard' && _isWin(g),
      ),
    ),
  ];

  static List<Achievement> unlockedFor(List<GameRecord> records) =>
      all.where((a) => a.isUnlocked(records)).toList();

  static List<String> unlockedIdsFor(List<GameRecord> records) =>
      unlockedFor(records).map((a) => a.id).toList();

  /// Достижения, которые разблокировались между "до" и "после" (обычно —
  /// до и после сохранения только что сыгранной партии).
  static List<Achievement> newlyUnlocked(
      List<GameRecord> before, List<GameRecord> after) {
    final beforeIds = unlockedIdsFor(before).toSet();
    return unlockedFor(after).where((a) => !beforeIds.contains(a.id)).toList();
  }
}
