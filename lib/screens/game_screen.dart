import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';
import '../utils/board_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/board_widget.dart';
import '../widgets/score_widget.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/chaos_background.dart';
import '../widgets/classic_background.dart';
import 'settings_screen.dart';

class GameScreen extends StatelessWidget {
  final GameMode gameMode;
  final BoardTheme initialTheme;
  final AppLanguage initialLanguage;
  final bool isModifierMode;
  final Function(AppLanguage)? onLanguageChanged;

  const GameScreen({
    Key? key,
    required this.gameMode,
    this.initialTheme = BoardTheme.night,
    this.initialLanguage = AppLanguage.english,
    this.isModifierMode = false,
    this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState()
        ..setGameMode(gameMode)
        ..setBoardTheme(initialTheme)
        ..setLanguage(initialLanguage)
        ..setModifierMode(isModifierMode),
      child: _GameScreenContent(onLanguageChanged: onLanguageChanged),
    );
  }
}

class _GameScreenContent extends StatefulWidget {
  final Function(AppLanguage)? onLanguageChanged;
  const _GameScreenContent({Key? key, this.onLanguageChanged}) : super(key: key);

  @override
  State<_GameScreenContent> createState() => _GameScreenContentState();
}

class _GameScreenContentState extends State<_GameScreenContent> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        final loc = gameState.loc;

        // Показываем диалог только один раз за партию
        if (gameState.isGameOver && !_dialogShown) {
          _dialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showGameOverDialog(context, gameState, loc);
          });
        }
        // Сбрасываем флаг когда началась новая игра
        if (!gameState.isGameOver && _dialogShown) {
          _dialogShown = false;
        }

        return WillPopScope(
          onWillPop: () async {
            if (gameState.isGameOver) return true;
            return await _showExitConfirmation(context, loc) ?? false;
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () async {
                  if (gameState.isGameOver) { Navigator.pop(context); return; }
                  final exit = await _showExitConfirmation(context, loc) ?? false;
                  if (exit && context.mounted) Navigator.pop(context);
                },
              ),
              title: Text(
                gameState.isModifierMode ? 'CHAOS' : loc.appTitle,
                style: TextStyle(
                  color: gameState.isModifierMode
                      ? const Color(0xFFFF6B35)
                      : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: gameState.isModifierMode ? 3 : 0,
                ),
              ),
              actions: [
                // Кнопка правил Chaos Mode
                if (gameState.isModifierMode)
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded,
                        color: Color(0xFFFF6B35)),
                    onPressed: () => _showChaosRules(context, loc),
                    tooltip: loc.chaosRulesTitle,
                  ),
                IconButton(
                  icon: Icon(
                    gameState.showValidMoves
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: gameState.toggleShowValidMoves,
                  tooltip: loc.toggleHints,
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => _showSettings(context, gameState),
                  tooltip: loc.settings,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => _showNewGameDialog(context, loc),
                  tooltip: loc.newGame,
                ),
              ],
            ),
            body: Stack(
              children: [
                // ── Огненный фон только в Chaos режиме ──────────────────────
                if (gameState.isModifierMode)
                  const Positioned.fill(child: ChaosBackground()),
                // ── Тёмный фон с листьями для обычного режима ───────────────
                if (!gameState.isModifierMode)
                  const Positioned.fill(child: ClassicBackground()),
                SafeArea(
                  child: Builder(builder: (context) {
                    return Column(
                      children: [
                        // ── Верхняя часть: счёт + индикатор игрока + доска ─────
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            child: Column(
                              children: [
                                ScoreWidget(
                                  blackScore: gameState.blackScore,
                                  whiteScore: gameState.whiteScore,
                                  currentPlayer: gameState.currentPlayer,
                                  blackLabel: loc.blackPlayer,
                                  whiteLabel: loc.whitePlayer,
                                ),
                                const SizedBox(height: 10),
                                _buildCurrentPlayerIndicator(gameState, loc),
                                const SizedBox(height: 10),
                                // Доска занимает всё оставшееся место
                                Expanded(
                                  child: Center(
                                    child: BoardWidget(
                                      board: gameState.board,
                                      validMoves: gameState.validMoves,
                                      showValidMoves: gameState.showValidMoves,
                                      onCellTap: (row, col) =>
                                          _handleCellTap(context, gameState, row, col),
                                      boardTheme: gameState.boardTheme,
                                      lastAIMove: gameState.lastAIMove,
                                      isAIThinking: gameState.isProcessing &&
                                          gameState.currentPlayer == Player.white &&
                                          gameState.gameMode == GameMode.vsAI,
                                      explosionCell: gameState.explosionCell,
                                      lastMoveCell: gameState.lastMoveCell,
                                      gameId: gameState.gameId,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── Нижняя зона ФИКСИРОВАННОЙ высоты — баннеры ─────────
                        // Высота не меняется → доска не прыгает
                        SizedBox(
                          height: 56,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (child, anim) => FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(anim),
                                  child: child,
                                ),
                              ),
                              child: _activeBanner(gameState, loc),
                            ),
                          ),
                        ),

                        // ── Рекламный баннер Google AdMob ───────────────────────
                        const AdBannerWidget(height: 52),
                      ],
                    );
                  }),
                ),
              ],
            ), // Stack
          ),
        );
      },
    );
  }

  // ── Выбирает какой баннер показать (только один за раз) ──────────────────
  Widget _activeBanner(GameState gameState, AppLocalizations loc) {
    // Приоритет: модификатор > пропуск хода > ИИ думает > пусто
    if (gameState.showModifierBanner) {
      return _bannerModifier(gameState.modifierBannerText,
          key: ValueKey('mod_${gameState.modifierBannerText}'));
    }
    if (gameState.showSkipBanner) {
      return _bannerSkip(loc, key: const ValueKey('skip'));
    }
    if (gameState.isProcessing &&
        gameState.gameMode == GameMode.vsAI &&
        gameState.currentPlayer == Player.white) {
      return _bannerAIThinking(loc, key: const ValueKey('ai'));
    }
    return const SizedBox.shrink(key: ValueKey('empty'));
  }

  Widget _bannerAIThinking(AppLocalizations loc, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00E5FF).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                  const Color(0xFF00E5FF).withOpacity(0.8)),
            ),
          ),
          const SizedBox(width: 10),
          Text(loc.aiThinking,
              style: const TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _bannerSkip(AppLocalizations loc, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 18),
          const SizedBox(width: 10),
          Flexible(
            child: Text(loc.noValidMoves,
                style: TextStyle(
                    color: Colors.orange.shade100, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _bannerModifier(String text, {Key? key}) {
    // Определяем цвет по контенту
    Color accent = Colors.deepPurpleAccent;
    if (text.contains('💥')) accent = const Color(0xFFFF6B35);
    if (text.contains('⭐')) accent = const Color(0xFFFFCC00);
    if (text.contains('🕳️')) accent = const Color(0xFF78909C);

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, color: accent, size: 18),
          const SizedBox(width: 10),
          Flexible(
            child: Text(text,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Правила Chaos Mode — красивый bottom sheet ────────────────────────────
  void _showChaosRules(BuildContext context, AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scroll) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A0F2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Color(0xFFFF6B35), width: 1.5),
            ),
          ),
          child: Column(
            children: [
              // Ручка
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Заголовок
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF1744), Color(0xFFAA00FF)],
                ).createShader(b),
                child: Text(
                  loc.chaosRulesTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                loc.chaosRulesIntro,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 12, height: 1.4),
              ),
              const Divider(color: Colors.white12, height: 24),
              // Список модификаторов
              Expanded(
                child: ListView(
                  controller: scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _ruleCard(
                      emoji: '🚫',
                      color: const Color(0xFF555555),
                      title: 'Blocked',
                      desc: loc.chaosRuleBlocked,
                    ),
                    _ruleCard(
                      emoji: '💥',
                      color: const Color(0xFFFF6B35),
                      title: 'Explosive',
                      desc: loc.chaosRuleExplosive,
                    ),
                    _ruleCard(
                      emoji: '⭐',
                      color: const Color(0xFFFFCC00),
                      title: 'Bonus',
                      desc: loc.chaosRuleBonus,
                    ),
                    _ruleCard(
                      emoji: '🕳️',
                      color: const Color(0xFF78909C),
                      title: 'Collapsing Floor',
                      desc: loc.chaosRuleTrapdoor,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        loc.chaosRuleSpawn,
                        style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ruleCard({
    required String emoji,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  // убираем префикс-эмодзи из строки — он уже в карточке
                  desc.replaceFirst(RegExp(r'^[^\s]+\s+[^\s]+\s+—\s*'), ''),
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Прочие виджеты ────────────────────────────────────────────────────────

  Widget _buildCurrentPlayerIndicator(GameState gameState, AppLocalizations loc) {
    final isBlack = gameState.currentPlayer == Player.black;
    final color = isBlack
        ? GameConstants.blackPlayerColor
        : GameConstants.whitePlayerColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18, height: 18,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            loc.turnOf(isBlack ? loc.blackPlayer : loc.whitePlayer),
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _handleCellTap(BuildContext context, GameState gs, int row, int col) {
    if (gs.isProcessing || !gs.isValidMove(row, col)) return;
    gs.makeMove(row, col);
  }

  void _showSettings(BuildContext context, GameState gameState) {
    final loc = gameState.loc;
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => SettingsScreen(
        currentTheme: gameState.boardTheme,
        soundEnabled: gameState.soundEnabled,
        onToggleSound: gameState.toggleSound,
        currentLanguage: gameState.language,
        onLanguageChanged: (lang) {
          gameState.setLanguage(lang);
          widget.onLanguageChanged?.call(lang);
        },
        onThemeChanged: (theme) {
          gameState.setBoardTheme(theme);
          Navigator.pop(context);
        },
        loc: loc,
      ),
    ));
  }

  Future<bool?> _showExitConfirmation(BuildContext context, loc) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameConstants.backgroundColor,
        title: Text(loc.leaveGameTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(loc.leaveGameConfirm,
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.stay, style: const TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.8)),
            child: Text(loc.leave),
          ),
        ],
      ),
    );
  }

  void _showNewGameDialog(BuildContext context, loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameConstants.backgroundColor,
        title: Text(loc.newGameTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(loc.newGameConfirm,
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel, style: const TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GameState>().newGame();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: GameConstants.boardColor),
            child: Text(loc.confirm),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, GameState gs, loc) {
    final isWin = gs.winner == Player.black ||
        (gs.gameMode == GameMode.vsPlayer && gs.winner != Player.none);
    final isDraw = gs.winner == Player.none;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _GameOverDialog(
        gs: gs,
        loc: loc,
        isWin: isWin,
        isDraw: isDraw,
        onPlayAgain: () {
          Navigator.pop(ctx);
          gs.newGame();
        },
        onMenu: () {
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildFinalScore(String label, int score, Color color) {
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(score.toString(),
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Диалог конца игры с эффектом конфетти
// ══════════════════════════════════════════════════════════════════════════════

class _Confetto {
  double x, y, speed, angle, rotation, rotSpeed, size;
  Color color;
  _Confetto({required this.x, required this.y, required this.speed,
    required this.angle, required this.rotation, required this.rotSpeed,
    required this.size, required this.color});
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetto> confetti;
  _ConfettiPainter(this.confetti);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final c in confetti) {
      paint.color = c.color;
      canvas.save();
      canvas.translate(c.x, c.y);
      canvas.rotate(c.rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter o) => true;
}

class _GameOverDialog extends StatefulWidget {
  final GameState gs;
  final dynamic loc;
  final bool isWin;
  final bool isDraw;
  final VoidCallback onPlayAgain;
  final VoidCallback onMenu;

  const _GameOverDialog({
    required this.gs,
    required this.loc,
    required this.isWin,
    required this.isDraw,
    required this.onPlayAgain,
    required this.onMenu,
  });

  @override
  State<_GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<_GameOverDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Confetto> _confetti;
  final _rng = math.Random();

  static const _colors = [
    Color(0xFFFF6B35), Color(0xFFFFCC00), Color(0xFF27AE60),
    Color(0xFF5DADE2), Color(0xFFAA00FF), Color(0xFFFF1744),
    Color(0xFF00E5FF), Color(0xFFFFFFFF),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _confetti = List.generate(80, (_) => _Confetto(
      x: _rng.nextDouble() * 400,
      y: -_rng.nextDouble() * 400,
      speed: 1.5 + _rng.nextDouble() * 3,
      angle: (_rng.nextDouble() - 0.5) * 0.5,
      rotation: _rng.nextDouble() * math.pi * 2,
      rotSpeed: (_rng.nextDouble() - 0.5) * 0.2,
      size: 6 + _rng.nextDouble() * 8,
      color: _colors[_rng.nextInt(_colors.length)],
    ));
    _ctrl.addListener(_updateConfetti);
  }

  void _updateConfetti() {
    if (!widget.isWin) return;
    setState(() {
      for (final c in _confetti) {
        c.y += c.speed;
        c.x += math.sin(c.angle) * 1.5;
        c.rotation += c.rotSpeed;
        if (c.y > 600) {
          c.y = -20;
          c.x = _rng.nextDouble() * 400;
        }
      }
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_updateConfetti);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gs = widget.gs;
    final loc = widget.loc;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Конфетти (только при победе)
          if (widget.isWin)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ConfettiPainter(_confetti),
                ),
              ),
            ),

          // Основной диалог
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: GameConstants.backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isDraw
                    ? Colors.white24
                    : widget.isWin
                    ? const Color(0xFFFFCC00)
                    : Colors.white24,
                width: 2,
              ),
              boxShadow: widget.isWin ? [
                BoxShadow(
                  color: const Color(0xFFFFCC00).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ] : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Эмодзи + заголовок
                Text(
                  widget.isDraw ? '🤝' : widget.isWin ? '🏆' : '😔',
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  gs.getWinnerText(),
                  style: GameConstants.titleStyle.copyWith(
                    fontSize: 26,
                    color: widget.isDraw
                        ? Colors.white70
                        : widget.isWin
                        ? const Color(0xFFFFCC00)
                        : Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Счёт
                Text(loc.finalScore,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _scoreBox(loc.blackPlayer, gs.blackScore,
                        GameConstants.blackPlayerColor,
                        isWinner: gs.winner == Player.black),
                    _scoreBox(loc.whitePlayer, gs.whiteScore,
                        GameConstants.whitePlayerColor,
                        isWinner: gs.winner == Player.white),
                  ],
                ),
                const SizedBox(height: 24),
                // Кнопки
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: widget.onPlayAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GameConstants.boardColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        loc.playAgain,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: widget.onMenu,
                      child: Text(
                        loc.menu,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreBox(String label, int score, Color color, {bool isWinner = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isWinner
            ? color.withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWinner ? color.withOpacity(0.6) : Colors.white12,
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: isWinner ? [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)
              ] : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  color: isWinner ? Colors.white : Colors.white54,
                  fontSize: 12)),
          const SizedBox(height: 2),
          Text(score.toString(),
              style: TextStyle(
                  color: isWinner ? Colors.white : Colors.white70,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}