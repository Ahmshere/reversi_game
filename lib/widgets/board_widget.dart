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

// ── Painter удара молнии ──────────────────────────────────────────────────────
class _LightningPainter extends CustomPainter {
  final double progress; // 0..1
  final Offset target;
  final List<Offset> bolt;
  final List<List<Offset>> branches;

  const _LightningPainter({
    required this.progress,
    required this.target,
    required this.bolt,
    required this.branches,
  });

  void _drawPolyline(Canvas canvas, List<Offset> pts, Paint paint) {
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || bolt.length < 2) return;

    // Фаза 1 (0.0-0.25): путь молнии стремительно "прочерчивается" сверху вниз
    final drawT = (progress / 0.25).clamp(0.0, 1.0);
    final visibleCount = (bolt.length * drawT).ceil().clamp(1, bolt.length);
    final visiblePath = bolt.sublist(0, visibleCount);

    double boltAlpha;
    if (progress < 0.5) {
      boltAlpha = 1.0;
    } else {
      final fadeT = ((progress - 0.5) / 0.5).clamp(0.0, 1.0);
      boltAlpha = (1 - fadeT) * (0.7 + 0.3 * math.sin(progress * math.pi * 18));
      boltAlpha = boltAlpha.clamp(0.0, 1.0);
    }

    // Внешнее фиолетовое свечение
    _drawPolyline(canvas, visiblePath, Paint()
      ..color = const Color(0xFF8A5CFF).withOpacity(0.55 * boltAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    // Среднее голубое свечение
    _drawPolyline(canvas, visiblePath, Paint()
      ..color = const Color(0xFF66E0FF).withOpacity(0.75 * boltAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

    // Яркое белое ядро
    _drawPolyline(canvas, visiblePath, Paint()
      ..color = Colors.white.withOpacity(boltAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Ответвления — только когда основной путь уже полностью прочерчен
    if (drawT >= 1.0) {
      for (final branch in branches) {
        _drawPolyline(canvas, branch, Paint()
          ..color = const Color(0xFF8A5CFF).withOpacity(0.4 * boltAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
        _drawPolyline(canvas, branch, Paint()
          ..color = Colors.white.withOpacity(0.85 * boltAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
      }
    }

    // Вспышка удара + искры в точке попадания
    if (progress > 0.18) {
      final flashT = ((progress - 0.18) / 0.35).clamp(0.0, 1.0);
      final flashFade = 1 - ((progress - 0.45) / 0.55).clamp(0.0, 1.0);
      final r = 14 + 46 * Curves.easeOut.transform(flashT);

      final flashPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.95 * flashFade),
            const Color(0xFF9B5CFF).withOpacity(0.6 * flashFade),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: target, radius: r));
      canvas.drawCircle(target, r, flashPaint);

      final sparkPaint = Paint()..strokeWidth = 2;
      for (int i = 0; i < 10; i++) {
        final a = i * math.pi * 2 / 10;
        final len = 10 + 26 * flashT;
        sparkPaint.color = const Color(0xFFBFE9FF).withOpacity(flashFade * 0.8);
        canvas.drawLine(
          Offset(target.dx + math.cos(a) * 6, target.dy + math.sin(a) * 6),
          Offset(target.dx + math.cos(a) * len, target.dy + math.sin(a) * len),
          sparkPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_LightningPainter oldDelegate) => true;
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
  final Cell? explosionCell;
  final Cell? bonusCell; // ← клетка сработавшего бонуса (доп. ход)
  final Cell? lightningCell; // ← клетка, в которую ударила молния
  final Cell? lastMoveCell;
  final Cell? hintCell; // ← клетка с подсказкой лучшего хода
  final int gameId;
  final bool isModifierMode; // ← передаём в CellWidget

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
    this.bonusCell,
    this.lightningCell,
    this.lastMoveCell,
    this.hintCell,
    this.gameId = 0,
    this.isModifierMode = false,
  }) : super(key: key);

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget>
    with TickerProviderStateMixin {

  late AnimationController _explosionCtrl;
  late Animation<double> _explosionAnim;
  List<_Particle> _particles = [];
  Cell? _activeExplosionCell;

  // ── Удар молнии ───────────────────────────────────────────────────────────
  late AnimationController _lightningCtrl;
  Cell? _activeLightningCell;
  List<double> _boltSegJitter = [];
  List<int> _boltBranchSeeds = [];

  // ── Анимация появления доски ─────────────────────────────────────────────
  late AnimationController _entranceCtrl;
  late Animation<double> _entranceScale;
  late Animation<double> _entranceFade;

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

    _lightningCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    // Появление доски при старте
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _entranceScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutBack),
    );
    _entranceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );
    // Запускаем сразу
    _entranceCtrl.forward();
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
    // Ударила молния
    if (widget.lightningCell != null &&
        oldWidget.lightningCell != widget.lightningCell) {
      final rng = math.Random();
      _activeLightningCell = widget.lightningCell;
      _boltSegJitter = List.generate(7, (_) => (rng.nextDouble() - 0.5) * 2);
      _boltBranchSeeds = List.generate(2, (_) => rng.nextInt(1 << 30));
      _lightningCtrl.forward(from: 0.0);
    }
    // Молния погасла
    if (widget.lightningCell == null && oldWidget.lightningCell != null) {
      _lightningCtrl.reset();
      _activeLightningCell = null;
    }
    // Новая игра — переиграть анимацию появления доски
    if (widget.lastMoveCell == null && oldWidget.lastMoveCell != null) {
      _entranceCtrl.forward(from: 0.0);
    }
  }

  // ── Путь молнии: от верха доски до клетки-цели ───────────────────────────
  List<Offset> _boltPathFor(Offset target) {
    final n = _boltSegJitter.length;
    final points = <Offset>[Offset(target.dx + _boltSegJitter[0] * 14, 0)];
    for (int i = 1; i < n; i++) {
      final t = i / (n - 1);
      final y = target.dy * t;
      final maxJitter = 30 * (1 - t * 0.4);
      final x = target.dx + _boltSegJitter[i] * maxJitter;
      points.add(Offset(x, y));
    }
    points.add(target);
    return points;
  }

  List<List<Offset>> _boltBranchesFor(List<Offset> bolt) {
    if (bolt.length < 4 || _boltBranchSeeds.isEmpty) return [];
    final branches = <List<Offset>>[];
    for (final seed in _boltBranchSeeds) {
      final rng = math.Random(seed);
      final startIdx = 1 + rng.nextInt(bolt.length - 3);
      final start = bolt[startIdx];
      final dir = rng.nextBool() ? 1 : -1;
      final branch = <Offset>[start];
      double x = start.dx, y = start.dy;
      for (int s = 0; s < 3; s++) {
        x += dir * (14 + rng.nextDouble() * 22);
        y += 12 + rng.nextDouble() * 18;
        branch.add(Offset(x, y));
      }
      branches.add(branch);
    }
    return branches;
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
    _lightningCtrl.dispose();
    _entranceCtrl.dispose();
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

    return AnimatedBuilder(
      animation: _entranceCtrl,
      builder: (_, child) => FadeTransition(
        opacity: _entranceFade,
        child: Transform.scale(
          scale: _entranceScale.value,
          child: child,
        ),
      ),
      child: AspectRatio(
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
                    color: widget.isModifierMode
                        ? themeData.gridLineColor.withOpacity(0.55)
                        : themeData.gridLineColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isModifierMode
                            ? const Color(0xFFFF4400).withOpacity(0.25)
                            : Colors.black.withOpacity(0.3),
                        blurRadius: widget.isModifierMode ? 20 : 10,
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
                      final isSuggested = widget.hintCell != null &&
                          widget.hintCell!.row == row &&
                          widget.hintCell!.col == col;
                      final isExplosionNeighbor = widget.explosionCell != null &&
                          !(row == widget.explosionCell!.row &&
                              col == widget.explosionCell!.col) &&
                          (row - widget.explosionCell!.row).abs() <= 1 &&
                          (col - widget.explosionCell!.col).abs() <= 1;
                      final isBonusTriggered = widget.bonusCell != null &&
                          widget.bonusCell!.row == row &&
                          widget.bonusCell!.col == col;

                      return CellWidget(
                        key: ValueKey('cell_${widget.gameId}_${row}_$col'),
                        cell: cell,
                        isValidMove: isValidMove,
                        showHint: showHint,
                        onTap: () => widget.onCellTap(row, col),
                        boardColor: themeData.boardColor,
                        gridLineColor: themeData.gridLineColor,
                        hintColor: themeData.hintColor,
                        isAITarget: isAITarget,
                        isAIThinking: widget.isAIThinking && isAITarget,
                        isModifierMode: widget.isModifierMode,
                        isSuggested: isSuggested,
                        isExplosionNeighbor: isExplosionNeighbor,
                        isBonusTriggered: isBonusTriggered,
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

                // ── Удар молнии — поверх доски ─────────────────────────────────
                if (_activeLightningCell != null)
                  AnimatedBuilder(
                    animation: _lightningCtrl,
                    builder: (_, __) {
                      final progress = _lightningCtrl.value;
                      if (progress <= 0) return const SizedBox.shrink();
                      final target = _cellCenter(_activeLightningCell!, boardSize);
                      final bolt = _boltPathFor(target);
                      return IgnorePointer(
                        child: CustomPaint(
                          size: boardSize,
                          painter: _LightningPainter(
                            progress: progress,
                            target: target,
                            bolt: bolt,
                            branches: _boltBranchesFor(bolt),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}