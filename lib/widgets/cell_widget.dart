import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../utils/constants.dart';

class CellWidget extends StatefulWidget {
  final Cell cell;
  final bool isValidMove;
  final bool showHint;
  final VoidCallback? onTap;
  final Color boardColor;
  final Color gridLineColor;
  final Color hintColor;
  final bool isAITarget;    // ← клетка куда собирается / походил ИИ
  final bool isAIThinking;  // ← ИИ ещё не сделал ход (мигающий контур)

  const CellWidget({
    Key? key,
    required this.cell,
    this.isValidMove = false,
    this.showHint = false,
    this.onTap,
    this.boardColor = GameConstants.boardColor,
    this.gridLineColor = GameConstants.gridLineColor,
    this.hintColor = GameConstants.validMoveColor,
    this.isAITarget = false,
    this.isAIThinking = false,
  }) : super(key: key);

  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget>
    with TickerProviderStateMixin {

  // ── Анимация фишки ───────────────────────────────────────────────────────
  late AnimationController _pieceCtrl;
  late Animation<double> _flipAnim;
  late Animation<double> _scaleAnim;
  Player? _previousPlayer;
  bool _isFlipping = false;

  // ── Анимация провала люка ────────────────────────────────────────────────
  late AnimationController _trapdoorCtrl;
  late Animation<double> _trapdoorY;      // фишка падает вниз
  late Animation<double> _trapdoorFade;   // исчезает
  late Animation<double> _trapdoorScale;  // сжимается
  late Animation<double> _crackAnim;      // трещины раскрываются
  late Animation<double> _pitAnim;        // яма появляется

  // ── Анимация взрыва ──────────────────────────────────────────────────────
  late AnimationController _explosionCtrl;
  late Animation<double> _explosionScale;
  late Animation<double> _explosionFade;
  bool _showExplosion = false;

  // ── Анимация подсветки ИИ ────────────────────────────────────────────────
  late AnimationController _aiGlowCtrl;
  late Animation<double> _aiGlowAnim;

  // ── Состояние ────────────────────────────────────────────────────────────
  bool _wasTrapdoor = false;

  @override
  void initState() {
    super.initState();

    // Фишка
    _pieceCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flipAnim = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _pieceCtrl, curve: Curves.easeInOut),
    );
    _scaleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pieceCtrl, curve: Curves.elasticOut),
    );

    // Провал
    _trapdoorCtrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _crackAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _trapdoorCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _trapdoorY = Tween<double>(begin: 0, end: 50).animate(
      CurvedAnimation(
        parent: _trapdoorCtrl,
        curve: const Interval(0.3, 0.75, curve: Curves.easeIn),
      ),
    );
    _trapdoorFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _trapdoorCtrl,
        curve: const Interval(0.45, 0.80, curve: Curves.easeIn),
      ),
    );
    _trapdoorScale = Tween<double>(begin: 1, end: 0.3).animate(
      CurvedAnimation(
        parent: _trapdoorCtrl,
        curve: const Interval(0.3, 0.75, curve: Curves.easeIn),
      ),
    );
    _pitAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _trapdoorCtrl,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Взрыв
    _explosionCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _explosionScale = Tween<double>(begin: 0.5, end: 2.2).animate(
      CurvedAnimation(parent: _explosionCtrl, curve: Curves.easeOut),
    );
    _explosionFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _explosionCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Подсветка ИИ
    _aiGlowCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _aiGlowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _aiGlowCtrl, curve: Curves.easeInOut),
    );

    _previousPlayer = widget.cell.player;
    if (!widget.cell.isEmpty) _pieceCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(CellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ── Начало провала ────────────────────────────────────────────────────
    if (!_wasTrapdoor && widget.cell.isTrapdoorFalling) {
      _wasTrapdoor = true;
      _trapdoorCtrl.forward(from: 0.0);
      return;
    }

    // ── Конец провала — сбрасываем ────────────────────────────────────────
    if (_wasTrapdoor && !widget.cell.isTrapdoorFalling) {
      _wasTrapdoor = false;
      _trapdoorCtrl.reset();
    }

    // ── Изменение фишки ───────────────────────────────────────────────────
    // ВАЖНО: Cell — мутируемый объект, oldWidget.cell IS widget.cell.
    // Поэтому сравниваем с _previousPlayer, который хранит старое значение.
    if (_previousPlayer != widget.cell.player && !widget.cell.isEmpty) {
      if (!_wasTrapdoor) {
        if (_previousPlayer == Player.none) {
          // Новая фишка — анимация появления (scale)
          _isFlipping = false;
          _pieceCtrl.forward(from: 0.0);
        } else {
          // Переворот — 3D анимация
          _isFlipping = true;
          _pieceCtrl.forward(from: 0.0);
        }
      }
      _previousPlayer = widget.cell.player;
    }

    // ── Фишка исчезла (после провала) — сбрасываем _previousPlayer ────────
    if (!_wasTrapdoor && widget.cell.isEmpty && _previousPlayer != Player.none) {
      _previousPlayer = Player.none;
      _pieceCtrl.reset();
    }
  }

  void _triggerExplosionFlash() {
    setState(() => _showExplosion = true);
    _explosionCtrl.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _showExplosion = false);
    });
  }

  @override
  void dispose() {
    _pieceCtrl.dispose();
    _trapdoorCtrl.dispose();
    _explosionCtrl.dispose();
    _aiGlowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modifier = widget.cell.cellType;
    final isTrapdoor = widget.cell.isTrapdoorFalling;

    return GestureDetector(
      onTap: widget.isValidMove ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pieceCtrl, _trapdoorCtrl, _explosionCtrl, _aiGlowCtrl,
        ]),
        builder: (context, _) {
          return Container(
            margin: const EdgeInsets.all(GameConstants.cellPadding),
            decoration: BoxDecoration(
              color: _cellBg(modifier, isTrapdoor),
              borderRadius: BorderRadius.circular(GameConstants.borderRadius),
              // Подсветка ИИ — мигающий цветной контур
              border: widget.isAITarget
                  ? Border.all(
                color: const Color(0xFF00E5FF)
                    .withOpacity(widget.isAIThinking
                    ? _aiGlowAnim.value
                    : 0.9),
                width: 2.0,
              )
                  : Border.all(
                color: _cellBorder(modifier),
                width: modifier != CellType.normal ? 1.0 : 0.5,
              ),
              // Glow вокруг цели ИИ
              boxShadow: widget.isAITarget
                  ? [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(
                      widget.isAIThinking ? _aiGlowAnim.value * 0.6 : 0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(GameConstants.borderRadius),
              child: Stack(
                children: [
                  // Штриховка заблокированных
                  if (modifier == CellType.blocked && !isTrapdoor)
                    const Positioned.fill(child: _HatchWidget()),

                  // Яма после провала
                  if (isTrapdoor && _pitAnim.value > 0)
                    _buildPit(),

                  // Иконка модификатора
                  if (widget.cell.isEmpty && modifier != CellType.normal && !isTrapdoor)
                    Center(child: _buildModifierIcon(modifier)),

                  // Подсказка
                  if (widget.showHint && !isTrapdoor)
                    Center(child: _buildHint()),

                  // Фишка
                  if (!widget.cell.isEmpty)
                    Center(child: _buildPieceAnimated(isTrapdoor)),

                  // Вспышка взрыва
                  if (_showExplosion)
                    _buildExplosionFlash(),

                  // Метка «ход ИИ» — маленькая стрелка сверху
                  if (widget.isAITarget && !widget.isAIThinking)
                    _buildAILabel(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Яма (тёмная дыра с радиальным градиентом) ────────────────────────────
  Widget _buildPit() {
    return Positioned.fill(
      child: Opacity(
        opacity: _pitAnim.value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GameConstants.borderRadius),
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8,
              colors: [
                Colors.black,
                const Color(0xFF1A0A00).withOpacity(0.85),
                Colors.transparent,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: Center(
            child: Opacity(
              opacity: (_pitAnim.value * 2 - 1).clamp(0.0, 1.0),
              child: const Text('🕳️',
                  style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ),
    );
  }

  // ── Анимация фишки (провал / переворот / появление) ───────────────────────
  Widget _buildPieceAnimated(bool isTrapdoor) {
    if (isTrapdoor) {
      // Трещина: клетка как-будто «раскалывается» — два куска расходятся,
      // фишка проваливается вниз
      return Stack(
        alignment: Alignment.center,
        children: [
          // Левая половина клетки
          ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: 0.5,
              child: Transform.translate(
                offset: Offset(
                  -_crackAnim.value * 4,
                  _trapdoorY.value * 0.3,
                ),
                child: Transform.rotate(
                  angle: -_crackAnim.value * 0.15,
                  child: Opacity(
                    opacity: _trapdoorFade.value.clamp(0.0, 1.0),
                    child: _buildPiece(widget.cell.player),
                  ),
                ),
              ),
            ),
          ),
          // Правая половина
          ClipRect(
            child: Align(
              alignment: Alignment.centerRight,
              widthFactor: 0.5,
              child: Transform.translate(
                offset: Offset(
                  _crackAnim.value * 4,
                  _trapdoorY.value * 0.3,
                ),
                child: Transform.rotate(
                  angle: _crackAnim.value * 0.15,
                  child: Opacity(
                    opacity: _trapdoorFade.value.clamp(0.0, 1.0),
                    child: _buildPiece(widget.cell.player),
                  ),
                ),
              ),
            ),
          ),
          // Основная фишка падает вниз
          Transform.translate(
            offset: Offset(0, _trapdoorY.value),
            child: Transform.scale(
              scale: _trapdoorScale.value,
              child: Opacity(
                opacity: _trapdoorFade.value.clamp(0.0, 1.0),
                child: _buildPiece(widget.cell.player),
              ),
            ),
          ),
        ],
      );
    }

    if (_isFlipping) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(_flipAnim.value),
        child: _buildPiece(
          _flipAnim.value > math.pi / 2
              ? widget.cell.player
              : _previousPlayer ?? widget.cell.player,
        ),
      );
    }

    return Transform.scale(
      scale: _scaleAnim.value,
      child: Transform.rotate(
        angle: (1 - _scaleAnim.value) * 0.5,
        child: _buildPiece(widget.cell.player),
      ),
    );
  }

  // ── Вспышка взрыва ────────────────────────────────────────────────────────
  Widget _buildExplosionFlash() {
    return Positioned.fill(
      child: Transform.scale(
        scale: _explosionScale.value,
        child: Opacity(
          opacity: _explosionFade.value.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF6030).withOpacity(0.7),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6030).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Text('💥', style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ),
    );
  }

  // ── Метка хода ИИ ────────────────────────────────────────────────────────
  Widget _buildAILabel() {
    return Positioned(
      top: 2,
      right: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        decoration: BoxDecoration(
          color: const Color(0xFF00E5FF).withOpacity(0.9),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'AI',
          style: TextStyle(
            color: Colors.black,
            fontSize: 7,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ── Подсказка ─────────────────────────────────────────────────────────────
  Widget _buildHint() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (_, v, __) => Transform.scale(
        scale: 0.75 + 0.25 * v,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: widget.hintColor.withOpacity(0.85 + 0.15 * v),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.hintColor.withOpacity(0.6 * v),
                blurRadius: 10 * v,
                spreadRadius: 2 * v,
              ),
            ],
          ),
        ),
      ),
      onEnd: () { if (mounted && widget.showHint) setState(() {}); },
    );
  }

  // ── Иконка модификатора ───────────────────────────────────────────────────
  Widget _buildModifierIcon(CellType type) {
    switch (type) {
      case CellType.blocked:
        return const Icon(Icons.block_rounded, color: Color(0xFF555555), size: 18);
      case CellType.explosive:
        return _glowEmoji('💥', const Color(0xFFFF6030));
      case CellType.bonus:
        return _glowEmoji('⭐', const Color(0xFFFFCC00));
      case CellType.normal:
        return const SizedBox.shrink();
    }
  }

  Widget _glowEmoji(String emoji, Color glow) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (_, v, __) => Transform.scale(
        scale: v,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: glow.withOpacity(0.5 * v),
                blurRadius: 10 * v,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 14)),
        ),
      ),
      onEnd: () { if (mounted) setState(() {}); },
    );
  }

  // ── Цвета клетки ─────────────────────────────────────────────────────────
  Color _cellBg(CellType type, bool isTrapdoor) {
    if (isTrapdoor) return const Color(0xFF0A0A0A);
    switch (type) {
      case CellType.blocked:   return const Color(0xFF1A1A1A);
      case CellType.explosive: return const Color(0xFF4A1500);
      case CellType.bonus:     return const Color(0xFF3D2A00);
      case CellType.normal:    return widget.boardColor;
    }
  }

  Color _cellBorder(CellType type) {
    switch (type) {
      case CellType.blocked:   return const Color(0xFF3A3A3A);
      case CellType.explosive: return const Color(0xFFE05020).withOpacity(0.8);
      case CellType.bonus:     return const Color(0xFFD4A000).withOpacity(0.8);
      case CellType.normal:    return widget.gridLineColor;
    }
  }

  // ── Фишка ────────────────────────────────────────────────────────────────
  Widget _buildPiece(Player player) {
    final isBlack = player == Player.black;
    return FractionallySizedBox(
      widthFactor: GameConstants.pieceScale,
      heightFactor: GameConstants.pieceScale,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isBlack
                    ? GameConstants.blackGradient
                    : GameConstants.whiteGradient,
                center: const Alignment(0.3, 0.4),
                radius: 0.85,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isBlack ? 0.5 : 0.25),
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: FractionallySizedBox(
              widthFactor: 0.55,
              heightFactor: 0.55,
              alignment: const Alignment(-0.55, -0.55),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(isBlack ? 0.28 : 0.75),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!isBlack)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.grey.withOpacity(0.3), width: 0.8),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Штриховка заблокированных клеток ────────────────────────────────────────
class _HatchWidget extends StatelessWidget {
  const _HatchWidget();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _HatchPainter());
  }
}

class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF333333)..strokeWidth = 1.0;
    for (double i = -size.height; i < size.width + size.height; i += 7) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), p);
    }
  }
  @override
  bool shouldRepaint(_HatchPainter _) => false;
}