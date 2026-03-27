import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../utils/constants.dart';

/// Виджет клетки игрового поля
class CellWidget extends StatefulWidget {
  final Cell cell;
  final bool isValidMove;
  final bool showHint;
  final VoidCallback? onTap;
  final Color boardColor;
  final Color gridLineColor;
  final Color hintColor;

  const CellWidget({
    Key? key,
    required this.cell,
    this.isValidMove = false,
    this.showHint = false,
    this.onTap,
    this.boardColor = GameConstants.boardColor,
    this.gridLineColor = GameConstants.gridLineColor,
    this.hintColor = GameConstants.validMoveColor,
  }) : super(key: key);

  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;
  Player? _previousPlayer;
  bool _isFlipping = false;

  // Для анимации провала
  late Animation<double> _trapdoorSlide;
  late Animation<double> _trapdoorFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: GameConstants.flipDuration,
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _trapdoorSlide = Tween<double>(begin: 0.0, end: 40.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.2, 1.0, curve: Curves.easeIn)),
    );
    _trapdoorFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 1.0, curve: Curves.easeIn)),
    );

    _previousPlayer = widget.cell.player;
    if (!widget.cell.isEmpty) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(CellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Анимация провала (люк)
    if (!oldWidget.cell.isTrapdoorFalling && widget.cell.isTrapdoorFalling) {
      _isFlipping = false;
      _controller.duration = const Duration(milliseconds: 800);
      _controller.forward(from: 0.0);
      _previousPlayer = widget.cell.player;
      return;
    }

    // Обычная анимация фишки
    if (_previousPlayer != widget.cell.player && !widget.cell.isEmpty) {
      _controller.duration = GameConstants.flipDuration;
      if (_previousPlayer == Player.none) {
        _isFlipping = false;
        _controller.forward(from: 0.0);
      } else {
        _isFlipping = true;
        _controller.forward(from: 0.0);
      }
      _previousPlayer = widget.cell.player;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modifier = widget.cell.cellType;
    final isTrapdoor = widget.cell.isTrapdoorFalling;

    return GestureDetector(
      onTap: widget.isValidMove ? widget.onTap : null,
      child: Container(
        margin: const EdgeInsets.all(GameConstants.cellPadding),
        decoration: BoxDecoration(
          color: _cellBackgroundColor(modifier),
          borderRadius: BorderRadius.circular(GameConstants.borderRadius),
          border: Border.all(
            color: _cellBorderColor(modifier),
            width: modifier != CellType.normal ? 1.0 : 0.5,
          ),
        ),
        child: Stack(
          children: [
            // ── Фоновый паттерн для заблокированных клеток ──────────────────
            if (modifier == CellType.blocked) _buildBlockedPattern(),

            // ── Иконка модификатора (только для пустых клеток) ──────────────
            if (widget.cell.isEmpty && modifier != CellType.normal)
              Center(child: _buildModifierIcon(modifier)),

            // ── Подсказка валидного хода ─────────────────────────────────────
            if (widget.showHint)
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  builder: (context, value, _) {
                    return Transform.scale(
                      scale: 0.75 + 0.25 * value,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: widget.hintColor.withOpacity(0.85 + 0.15 * value),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.hintColor.withOpacity(0.6 * value),
                              blurRadius: 10 * value,
                              spreadRadius: 2 * value,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onEnd: () { if (mounted && widget.showHint) setState(() {}); },
                ),
              ),

            // ── Фишка ────────────────────────────────────────────────────────
            if (!widget.cell.isEmpty)
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    // Анимация провала (люк)
                    if (isTrapdoor) {
                      return Transform.translate(
                        offset: Offset(0, _trapdoorSlide.value),
                        child: Opacity(
                          opacity: _trapdoorFade.value.clamp(0.0, 1.0),
                          child: _buildPiece(widget.cell.player),
                        ),
                      );
                    }
                    // 3D переворот
                    if (_isFlipping) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_flipAnimation.value),
                        child: _buildPiece(
                          _flipAnimation.value > math.pi / 2
                              ? widget.cell.player
                              : _previousPlayer ?? widget.cell.player,
                        ),
                      );
                    }
                    // Появление
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: (1 - _scaleAnimation.value) * 0.5,
                        child: _buildPiece(widget.cell.player),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Цвета клеток по типу модификатора ──────────────────────────────────

  Color _cellBackgroundColor(CellType type) {
    switch (type) {
      case CellType.blocked:
        return const Color(0xFF1A1A1A); // тёмно-серый
      case CellType.explosive:
        return const Color(0xFF4A1500); // тёмно-красный
      case CellType.bonus:
        return const Color(0xFF3D2A00); // тёмно-золотой
      case CellType.normal:
        return widget.boardColor;
    }
  }

  Color _cellBorderColor(CellType type) {
    switch (type) {
      case CellType.blocked:
        return const Color(0xFF3A3A3A);
      case CellType.explosive:
        return const Color(0xFFE05020).withOpacity(0.8);
      case CellType.bonus:
        return const Color(0xFFD4A000).withOpacity(0.8);
      case CellType.normal:
        return widget.gridLineColor;
    }
  }

  // ── Паттерн для заблокированных клеток ─────────────────────────────────

  Widget _buildBlockedPattern() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(GameConstants.borderRadius),
      child: CustomPaint(
        painter: _HatchPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ── Иконки модификаторов ─────────────────────────────────────────────────

  Widget _buildModifierIcon(CellType type) {
    switch (type) {
      case CellType.blocked:
        return const Icon(Icons.block_rounded,
            color: Color(0xFF555555), size: 18);
      case CellType.explosive:
        return _buildGlowIcon('💥', const Color(0xFFFF6030));
      case CellType.bonus:
        return _buildGlowIcon('⭐', const Color(0xFFFFCC00));
      case CellType.normal:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGlowIcon(String emoji, Color glowColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (_, val, __) {
        return Transform.scale(
          scale: val,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.5 * val),
                  blurRadius: 10 * val,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 14)),
          ),
        );
      },
      onEnd: () { if (mounted) setState(() {}); },
    );
  }

  // ── Рендер фишки ─────────────────────────────────────────────────────────

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
                BoxShadow(
                  color: Colors.black.withOpacity(isBlack ? 0.3 : 0.12),
                  blurRadius: 3,
                  offset: const Offset(1, 2),
                  spreadRadius: -1,
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

/// CustomPainter для диагональной штриховки заблокированных клеток
class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 1.0;

    const step = 7.0;
    for (double i = -size.height; i < size.width + size.height; i += step) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HatchPainter _) => false;
}
