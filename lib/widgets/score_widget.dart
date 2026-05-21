import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Виджет счёта с пульсацией активного игрока и анимацией цифр
class ScoreWidget extends StatefulWidget {
  final int blackScore;
  final int whiteScore;
  final Player currentPlayer;
  final String blackLabel;
  final String whiteLabel;

  const ScoreWidget({
    Key? key,
    required this.blackScore,
    required this.whiteScore,
    required this.currentPlayer,
    this.blackLabel = 'Black',
    this.whiteLabel = 'White',
  }) : super(key: key);

  @override
  State<ScoreWidget> createState() => _ScoreWidgetState();
}

class _ScoreWidgetState extends State<ScoreWidget>
    with TickerProviderStateMixin {

  // ── Пульсация активного игрока ───────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // ── Анимация счёта ───────────────────────────────────────────────────────
  late AnimationController _blackScoreCtrl;
  late AnimationController _whiteScoreCtrl;
  late Animation<double> _blackScoreAnim;
  late Animation<double> _whiteScoreAnim;

  int _prevBlack = 0;
  int _prevWhite = 0;

  @override
  void initState() {
    super.initState();

    // Пульсация — мягкое биение
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOutSine),
    );

    // Анимация счёта
    _blackScoreCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _whiteScoreCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _prevBlack = widget.blackScore;
    _prevWhite = widget.whiteScore;

    _blackScoreAnim = Tween<double>(
      begin: widget.blackScore.toDouble(),
      end: widget.blackScore.toDouble(),
    ).animate(CurvedAnimation(
      parent: _blackScoreCtrl,
      curve: Curves.easeOutCubic,
    ));

    _whiteScoreAnim = Tween<double>(
      begin: widget.whiteScore.toDouble(),
      end: widget.whiteScore.toDouble(),
    ).animate(CurvedAnimation(
      parent: _whiteScoreCtrl,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(ScoreWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Анимируем изменение чёрного счёта
    if (oldWidget.blackScore != widget.blackScore) {
      _blackScoreAnim = Tween<double>(
        begin: _prevBlack.toDouble(),
        end: widget.blackScore.toDouble(),
      ).animate(CurvedAnimation(
        parent: _blackScoreCtrl,
        curve: Curves.easeOutCubic,
      ));
      _prevBlack = widget.blackScore;
      _blackScoreCtrl.forward(from: 0.0);
    }

    // Анимируем изменение белого счёта
    if (oldWidget.whiteScore != widget.whiteScore) {
      _whiteScoreAnim = Tween<double>(
        begin: _prevWhite.toDouble(),
        end: widget.whiteScore.toDouble(),
      ).animate(CurvedAnimation(
        parent: _whiteScoreCtrl,
        curve: Curves.easeOutCubic,
      ));
      _prevWhite = widget.whiteScore;
      _whiteScoreCtrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _blackScoreCtrl.dispose();
    _whiteScoreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnim, _blackScoreAnim, _whiteScoreAnim,
        ]),
        builder: (_, __) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPlayerScore(
              color: GameConstants.blackPlayerColor,
              scoreAnim: _blackScoreAnim,
              isActive: widget.currentPlayer == Player.black,
              label: widget.blackLabel,
            ),
            Container(
              width: 2,
              height: 40,
              color: Colors.white.withOpacity(0.3),
            ),
            _buildPlayerScore(
              color: GameConstants.whitePlayerColor,
              scoreAnim: _whiteScoreAnim,
              isActive: widget.currentPlayer == Player.white,
              label: widget.whiteLabel,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerScore({
    required Color color,
    required Animation<double> scoreAnim,
    required bool isActive,
    required String label,
  }) {
    // Пульсация только у активного игрока
    final pulseScale = isActive ? _pulseAnim.value : 1.0;
    final glowOpacity = isActive
        ? 0.3 + (_pulseAnim.value - 0.85) / 0.15 * 0.4
        : 0.0;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Фишка с пульсацией
            Transform.scale(
              scale: pulseScale,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive
                        ? Colors.yellowAccent.withOpacity(glowOpacity + 0.3)
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: Colors.yellowAccent.withOpacity(glowOpacity),
                      blurRadius: 12 * pulseScale,
                      spreadRadius: 3 * pulseScale,
                    ),
                  ]
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GameConstants.scoreStyle.copyWith(
                fontSize: 16,
                color: isActive ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Счёт — анимированные цифры
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Text(
            scoreAnim.value.round().toString(),
            key: ValueKey(scoreAnim.value.round()),
            style: GameConstants.scoreStyle.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}