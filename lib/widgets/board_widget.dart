import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/cell.dart';
import '../utils/constants.dart';
import '../utils/board_theme.dart';
import 'cell_widget.dart';

// ── Частица взрыва ───────────────────────────────────────────────────────────
class _Particle {
  final double angle;   // направление вылета
  final double speed;   // скорость
  final double size;    // размер
  final Color color;
  final double rotSpeed;

  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotSpeed,
  });
}

// ── Painter взрыва ───────────────────────────────────────────────────────────
class _ExplosionPainter extends CustomPainter {
  final double progress;   // 0..1
  final Offset center;     // центр взрыва в координатах виджета
  final List<_Particle> particles;

  const _ExplosionPainter({
    required this.progress,
    required this.center,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final eased = Curves.easeOut.transform(progress);

    // Ударная волна — кольцо
    final wavePaint = Paint()
      ..color = const Color(0xFFFF8C00).withOpacity((1 - progress) * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 * (1 - progress);
    canvas.drawCircle(center, eased * 80, wavePaint);

    // Второе кольцо (чуть меньше, белое)
    final wave2Paint = Paint()
      ..color = Colors.white.withOpacity((1 - progress) * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * (1 - progress);
    canvas.drawCircle(center, eased * 55, wave2Paint);

    // Вспышка в центре
    if (progress < 0.4) {
      final flashAlpha = (1 - progress / 0.4);
      final gPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(flashAlpha * 0.9),
            const Color(0xFFFF6B00).withOpacity(flashAlpha * 0.6),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: 50));
      canvas.drawCircle(center, 50 * (1 - progress * 0.5), gPaint);
    }

    // Частицы
    for (final p in particles) {
      final dist = p.speed * eased * 90;
      final px = center.dx + math.cos(p.angle) * dist;
      final py = center.dy + math.sin(p.angle) * dist;
      final alpha = (1 - eased).clamp(0.0, 1.0);
      final rotation = p.rotSpeed * progress * math.pi * 4;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rotation);

      // Некоторые частицы — кружки, некоторые — ромбы
      final paint = Paint()..color = p.color.withOpacity(alpha);
      if (p.rotSpeed > 0) {
        // Ромб
        final path = Path()
          ..moveTo(0, -p.size)
          ..lineTo(p.size * 0.6, 0)
          ..lineTo(0, p.size)
          ..lineTo(-p.size * 0.6, 0)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(Offset.zero, p.size, paint);
      }

      canvas.restore();
    }

    // Мелкие искры
    final sparkPaint = Paint()..strokeWidth = 2;
    for (int i = 0; i < 12; i++) {
      final a = i * math.pi * 2 / 12;
      final sparkLen = 20 + 30 * eased;
      final alpha = (1 - eased * 1.5).clamp(0.0, 1.0);
      sparkPaint.color = const Color(0xFFFFDD00).withOpacity(alpha);
      canvas.drawLine(
        Offset(center.dx + math.cos(a) * 15,
            center.dy + math.sin(a) * 15),
        Offset(center.dx + math.cos(a) * sparkLen,
            center.dy + math.sin(a) * sparkLen),
        sparkPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ExplosionPainter o) => o.progress != progress;
}

// ── BoardWidget ──────────────────────────────────────────────────────────────
class BoardWidget extends StatefulWidget {
  final Board board;
  final List<Cell> validMoves;
  final bool showValidMoves;
  final Function(int row, int col) onCellTap;
  final BoardTheme boardTheme;
  final Cell? lastAIMove;
  final bool isAIThinking;
  final Cell? explosionCell;   // ← координата взрыва

  const BoardWidget({
    Key? key,
    required this.board,
    required this.validMoves,
    required this.showValidMoves,
    required this.onCellTap,
    this.boardTheme = BoardTheme.classic,
    this.lastAIMove,
    this.isAIThinking = false,
    this.explosionCell,
  }) : super(key: key);

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget>
    with SingleTickerProviderStateMixin {

  late AnimationController _explosionCtrl;
  late Animation<double> _explosionAnim;
  List<_Particle> _particles = [];
  Cell? _activeExplosionCell;

  @override
  void initState() {
    super.initState();
    _explosionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _explosionAnim = CurvedAnimation(
      parent: _explosionCtrl,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(BoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Взрыв появился
    if (widget.explosionCell != null &&
        oldWidget.explosionCell != widget.explosionCell) {
      _activeExplosionCell = widget.explosionCell;
      _particles = _generateParticles();
      _explosionCtrl.forward(from: 0.0);
    }
    // Взрыв убрали
    if (widget.explosionCell == null && oldWidget.explosionCell != null) {
      _explosionCtrl.reset();
      _activeExplosionCell = null;
    }
  }

  List<_Particle> _generateParticles() {
    final rng = math.Random();
    final colors = [
      const Color(0xFFFF6B00),
      const Color(0xFFFF3300),
      const Color(0xFFFFCC00),
      const Color(0xFFFF9900),
      Colors.white,
      const Color(0xFFFF4444),
    ];
    return List.generate(24, (i) => _Particle(
      angle: rng.nextDouble() * math.pi * 2,
      speed: 0.5 + rng.nextDouble() * 0.8,
      size: 3 + rng.nextDouble() * 7,
      color: colors[rng.nextInt(colors.length)],
      rotSpeed: (rng.nextDouble() - 0.5) * 3,
    ));
  }

  @override
  void dispose() {
    _explosionCtrl.dispose();
    super.dispose();
  }

  // Вычисляем центр клетки в координатах всего виджета
  Offset _cellCenter(Cell cell, Size boardSize) {
    const padding = 8.0;
    final gridSize = boardSize.width - padding * 2;
    final cellSize = gridSize / GameConstants.boardSize;
    return Offset(
      padding + (cell.col + 0.5) * cellSize,
      padding + (cell.row + 0.5) * cellSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = BoardThemeData.getTheme(widget.boardTheme);

    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            children: [
              // ── Сетка клеток ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeData.gridLineColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: GameConstants.boardSize,
                  ),
                  itemCount: GameConstants.boardSize * GameConstants.boardSize,
                  itemBuilder: (context, index) {
                    final row = index ~/ GameConstants.boardSize;
                    final col = index % GameConstants.boardSize;
                    final cell = widget.board.getCell(row, col);
                    final isValidMove = widget.validMoves
                        .any((c) => c.row == row && c.col == col);
                    final showHint = widget.showValidMoves && isValidMove;
                    final isAITarget = widget.lastAIMove != null &&
                        widget.lastAIMove!.row == row &&
                        widget.lastAIMove!.col == col;

                    return CellWidget(
                      key: ValueKey('cell_${row}_$col'),
                      cell: cell,
                      isValidMove: isValidMove,
                      showHint: showHint,
                      onTap: () => widget.onCellTap(row, col),
                      boardColor: themeData.boardColor,
                      gridLineColor: themeData.gridLineColor,
                      hintColor: themeData.hintColor,
                      isAITarget: isAITarget,
                      isAIThinking: widget.isAIThinking && isAITarget,
                    );
                  },
                ),
              ),

              // ── Взрыв — поверх доски ──────────────────────────────────────
              if (_activeExplosionCell != null)
                AnimatedBuilder(
                  animation: _explosionAnim,
                  builder: (_, __) {
                    if (_explosionAnim.value <= 0) return const SizedBox.shrink();
                    return IgnorePointer(
                      child: CustomPaint(
                        size: boardSize,
                        painter: _ExplosionPainter(
                          progress: _explosionAnim.value,
                          center: _cellCenter(_activeExplosionCell!, boardSize),
                          particles: _particles,
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}