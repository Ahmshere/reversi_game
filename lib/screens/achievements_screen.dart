import 'package:flutter/material.dart';
import 'game_stats.dart';
import '../utils/achievements.dart';
import '../utils/app_localizations.dart';
import '../utils/constants.dart';

/// Экран со списком всех достижений — открытых и ещё заблокированных.
class AchievementsScreen extends StatefulWidget {
  final AppLocalizations loc;
  const AchievementsScreen({Key? key, required this.loc}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    final l = widget.loc;
    final records = StatsRepository().records;
    final unlockedIds = Achievements.unlockedIdsFor(records).toSet();
    final total = Achievements.all.length;
    final unlockedCount = unlockedIds.length;
    final progress = total == 0 ? 0.0 : unlockedCount / total;

    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.achievementsTitle,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: _buildProgressHeader(l, unlockedCount, total, progress),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: Achievements.all.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final a = Achievements.all[index];
                  final unlocked = unlockedIds.contains(a.id);
                  return _AchievementCard(
                    achievement: a,
                    unlocked: unlocked,
                    loc: l,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(
      AppLocalizations l, int unlocked, int total, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: Color(0xFFFFCC00), size: 22),
              const SizedBox(width: 8),
              Text(
                l.achievementsProgress(unlocked, total),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xFFFFCC00)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;
  final AppLocalizations loc;

  const _AchievementCard({
    required this.achievement,
    required this.unlocked,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final accent = unlocked ? const Color(0xFFFFCC00) : Colors.white24;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFFFFCC00).withOpacity(0.08)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(unlocked ? 0.5 : 0.15)),
      ),
      child: Row(
        children: [
          // Эмодзи-иконка достижения
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? const Color(0xFFFFCC00).withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
            ),
            child: Opacity(
              opacity: unlocked ? 1.0 : 0.35,
              child: Text(achievement.emoji,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title(loc),
                  style: TextStyle(
                    color: unlocked ? Colors.white : Colors.white54,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  achievement.description(loc),
                  style: TextStyle(
                    color: unlocked ? Colors.white70 : Colors.white38,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            color: unlocked ? const Color(0xFFFFCC00) : Colors.white24,
            size: 22,
          ),
        ],
      ),
    );
  }
}
