import 'package:flutter/material.dart';
import 'game_stats.dart';
import '../utils/app_localizations.dart';
import '../utils/constants.dart';
import 'game_stats.dart';

class StatsScreen extends StatefulWidget {
  final AppLocalizations loc;
  const StatsScreen({Key? key, required this.loc}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _repo = StatsRepository();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.loc;

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
          l.statsTitle,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_repo.records.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white54),
              onPressed: () => _confirmClear(context, l),
              tooltip: l.statsClear,
            ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: const Color(0xFF27AE60),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(text: l.statsClassic),
            Tab(
              child: ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFAA00FF)],
                ).createShader(b),
                child: Text(l.statsChaos,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildList(_repo.classicRecords, l, isChaos: false),
          _buildList(_repo.chaosRecords, l, isChaos: true),
        ],
      ),
    );
  }

  Widget _buildList(List<GameRecord> records, AppLocalizations l,
      {required bool isChaos}) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_esports_outlined,
                color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(l.statsEmpty,
                style:
                const TextStyle(color: Colors.white38, fontSize: 16)),
          ],
        ),
      );
    }

    // Сводка вверху
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _buildSummary(records, l, isChaos),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildCard(records[i], l, isChaos),
              childCount: records.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  // ── Сводная статистика ───────────────────────────────────────────────────
  Widget _buildSummary(
      List<GameRecord> records, AppLocalizations l, bool isChaos) {
    final wins = records.where((r) => r.winner == 'black').length;
    final losses = records.where((r) => r.winner == 'white').length;
    final draws = records.where((r) => r.winner == 'draw').length;
    final avgMoves = records.isEmpty
        ? 0
        : records.fold(0, (s, r) => s + r.totalMoves) ~/ records.length;

    return Column(
      children: [
        Row(
          children: [
            _statChip(records.length.toString(), l.statsGames,
                const Color(0xFF5DADE2)),
            const SizedBox(width: 10),
            _statChip(wins.toString(), l.statsWins,
                const Color(0xFF27AE60)),
            const SizedBox(width: 10),
            _statChip(losses.toString(), l.statsLosses,
                const Color(0xFFE74C3C)),
            const SizedBox(width: 10),
            _statChip(draws.toString(), l.statsDraws,
                const Color(0xFF95A5A6)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _statChip('$avgMoves', l.statsAvgMoves,
                const Color(0xFF9B59B6)),
            if (isChaos) ...[
              const SizedBox(width: 10),
              _statChip(
                records.fold(0, (s, r) => s + r.trapdoorDrops).toString(),
                l.statsTrapdoors,
                const Color(0xFF78909C),
              ),
              const SizedBox(width: 10),
              _statChip(
                records.fold(0, (s, r) => s + r.explosionFlips).toString(),
                l.statsExplosions,
                const Color(0xFFFF6B35),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: Colors.white.withOpacity(0.1)),
      ],
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 10, height: 1.2)),
          ],
        ),
      ),
    );
  }

  // ── Карточка одной партии ────────────────────────────────────────────────
  Widget _buildCard(GameRecord r, AppLocalizations l, bool isChaos) {
    final winColor = r.winner == 'black'
        ? const Color(0xFF27AE60)
        : r.winner == 'white'
        ? const Color(0xFF5DADE2)
        : const Color(0xFF95A5A6);

    final winIcon = r.winner == 'black'
        ? '⚫'
        : r.winner == 'white'
        ? '⚪'
        : '🤝';

    final dateStr = _formatDate(r.dateTime);
    final timeStr = _formatTime(r.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: winColor.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Шапка: дата + победитель
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    color: Colors.white38, size: 13),
                const SizedBox(width: 5),
                Text('$dateStr  $timeStr',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12)),
                const Spacer(),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: winColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: winColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    '$winIcon ${_winnerLabel(r.winner, l)}',
                    style: TextStyle(
                        color: winColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Счёт
            Row(
              children: [
                _pieceScore('⚫', r.blackScore,
                    r.winner == 'black', l),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('vs',
                      style: TextStyle(color: Colors.white38, fontSize: 13)),
                ),
                _pieceScore('⚪', r.whiteScore,
                    r.winner == 'white', l),
                const Spacer(),
                // Противник
                Icon(
                  r.opponent == 'ai'
                      ? Icons.smart_toy_rounded
                      : Icons.people_alt_rounded,
                  color: Colors.white38,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  r.opponent == 'ai' ? l.vsComputer : l.vsPlayer,
                  style:
                  const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Детали
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _tag(Icons.swap_horiz_rounded,
                    '${l.statsMoves}: ${r.totalMoves}',
                    const Color(0xFF9B59B6)),
                _tag(Icons.flip_rounded,
                    '⚫ ${r.blackFlipped}  ⚪ ${r.whiteFlipped}',
                    const Color(0xFF5DADE2)),
                if (isChaos && r.trapdoorDrops > 0)
                  _tag(Icons.arrow_downward_rounded,
                      '🕳️ ${r.trapdoorDrops}',
                      const Color(0xFF78909C)),
                if (isChaos && r.explosionFlips > 0)
                  _tag(Icons.local_fire_department_rounded,
                      '💥 ${r.explosionFlips}',
                      const Color(0xFFFF6B35)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pieceScore(String emoji, int score, bool isWinner,
      AppLocalizations l) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(
          score.toString(),
          style: TextStyle(
            color: isWinner ? Colors.white : Colors.white60,
            fontSize: 18,
            fontWeight:
            isWinner ? FontWeight.w800 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _tag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color.withOpacity(0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _winnerLabel(String winner, AppLocalizations l) {
    if (winner == 'black') return l.blackPlayer;
    if (winner == 'white') return l.whitePlayer;
    return l.draw;
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  void _confirmClear(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameConstants.backgroundColor,
        title: Text(l.statsClearTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(l.statsClearConfirm,
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel,
                style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _repo.clear());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.8)),
            child: Text(l.confirm,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}