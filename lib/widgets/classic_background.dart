import 'dart:math' as math;
import 'package:flutter/material.dart';

// ── Листок ───────────────────────────────────────────────────────────────────
class _Leaf {
  double x, y;
  double vx, vy;
  double size;
  double alpha;
  double rotation;
  double rotSpeed;
  double swayPhase;   // фаза покачивания
  double swayAmp;     // амплитуда покачивания
  final _LeafShape shape;
  final Color color;

  _Leaf({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.alpha,
    required this.rotation,
    required this.rotSpeed,
    required this.swayPhase,
    required this.swayAmp,
    required this.shape,
    required this.color,
  });
}

enum _LeafShape { oval, maple, round, elongated }

// ── Painter ───────────────────────────────────────────────────────────────────
class _LeafPainter extends CustomPainter {
  final List<_Leaf> leaves;
  final double time;

  const _LeafPainter({required this.leaves, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // Фоновый градиент — глубокий тёмно-зелёный/синий лес
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0A1628),
          const Color(0xFF0D2137),
          const Color(0xFF0A1F1A),
          const Color(0xFF071510),
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Лунный свет сверху
    final moonGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6AAFE6).withOpacity(0.12),
          const Color(0xFF3A7FBF).withOpacity(0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.75, -size.height * 0.05),
        radius: size.width * 0.8,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.75, -size.height * 0.05),
        size.width * 0.8,
        moonGlow);

    // Мягкое свечение снизу (земля/трава)
    final groundGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1A4A2A).withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height),
        radius: size.width * 0.7,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height),
        size.width * 0.7,
        groundGlow);

    // Рисуем листья
    for (final leaf in leaves) {
      _drawLeaf(canvas, leaf);
    }
  }

  void _drawLeaf(Canvas canvas, _Leaf leaf) {
    canvas.save();
    canvas.translate(leaf.x, leaf.y);
    canvas.rotate(leaf.rotation);

    final paint = Paint()
      ..color = leaf.color.withOpacity(leaf.alpha)
      ..style = PaintingStyle.fill;

    final veinPaint = Paint()
      ..color = leaf.color.withOpacity(leaf.alpha * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    switch (leaf.shape) {
      case _LeafShape.oval:
        _drawOvalLeaf(canvas, leaf.size, paint, veinPaint);
        break;
      case _LeafShape.maple:
        _drawMapleLeaf(canvas, leaf.size, paint, veinPaint);
        break;
      case _LeafShape.round:
        _drawRoundLeaf(canvas, leaf.size, paint, veinPaint);
        break;
      case _LeafShape.elongated:
        _drawElongatedLeaf(canvas, leaf.size, paint, veinPaint);
        break;
    }

    canvas.restore();
  }

  void _drawOvalLeaf(Canvas canvas, double size, Paint p, Paint vp) {
    final path = Path()
      ..moveTo(0, -size)
      ..cubicTo(size * 0.6, -size * 0.6, size * 0.6, size * 0.6, 0, size)
      ..cubicTo(-size * 0.6, size * 0.6, -size * 0.6, -size * 0.6, 0, -size);
    canvas.drawPath(path, p);
    // Центральная прожилка
    canvas.drawLine(Offset(0, -size * 0.8), Offset(0, size * 0.8), vp);
    // Боковые
    for (int i = -2; i <= 2; i++) {
      final y = i * size * 0.3;
      canvas.drawLine(
          Offset(0, y), Offset(size * 0.45 * (i.isEven ? 1 : -1), y - size * 0.15), vp);
    }
  }

  void _drawMapleLeaf(Canvas canvas, double size, Paint p, Paint vp) {
    // Простой трёхлопастной лист вместо звезды
    final path = Path();
    final s = size;
    // Центральная лопасть (вверх)
    path.moveTo(0, 0);
    path.cubicTo(-s * 0.4, -s * 0.3, -s * 0.3, -s * 1.1, 0, -s * 1.2);
    path.cubicTo(s * 0.3, -s * 1.1, s * 0.4, -s * 0.3, 0, 0);
    // Левая лопасть
    path.moveTo(0, -s * 0.3);
    path.cubicTo(-s * 0.3, -s * 0.5, -s * 1.1, -s * 0.4, -s * 1.1, -s * 0.1);
    path.cubicTo(-s * 1.0, s * 0.1, -s * 0.3, 0, 0, -s * 0.3);
    // Правая лопасть
    path.moveTo(0, -s * 0.3);
    path.cubicTo(s * 0.3, -s * 0.5, s * 1.1, -s * 0.4, s * 1.1, -s * 0.1);
    path.cubicTo(s * 1.0, s * 0.1, s * 0.3, 0, 0, -s * 0.3);
    canvas.drawPath(path, p);
    // Прожилки
    canvas.drawLine(const Offset(0, 0), Offset(0, -s * 1.1), vp);
    canvas.drawLine( Offset(0, -s * 0.3), Offset(-s * 1.0, -s * 0.1), vp);
    canvas.drawLine( Offset(0, -s * 0.3), Offset(s * 1.0, -s * 0.1), vp);
  }

  void _drawRoundLeaf(Canvas canvas, double size, Paint p, Paint vp) {
    // Каплевидный лист с заострённым кончиком
    final path = Path()
      ..moveTo(0, -size * 0.9)
      ..cubicTo(size * 0.7, -size * 0.7, size * 0.8, size * 0.3, 0, size * 0.9)
      ..cubicTo(-size * 0.8, size * 0.3, -size * 0.7, -size * 0.7, 0, -size * 0.9);
    canvas.drawPath(path, p);
    canvas.drawLine(Offset(0, -size * 0.8), Offset(0, size * 0.8), vp);
    for (int i = -2; i <= 2; i++) {
      if (i == 0) continue;
      final y = i * size * 0.28;
      final xEnd = size * 0.5 * (i < 0 ? 1 : -1);
      canvas.drawLine(Offset(0, y), Offset(xEnd, y - size * 0.12), vp);
    }
  }

  void _drawElongatedLeaf(Canvas canvas, double size, Paint p, Paint vp) {
    final path = Path()
      ..moveTo(0, -size * 1.2)
      ..cubicTo(size * 0.35, -size * 0.6, size * 0.35, size * 0.6, 0, size * 1.2)
      ..cubicTo(-size * 0.35, size * 0.6, -size * 0.35, -size * 0.6, 0, -size * 1.2);
    canvas.drawPath(path, p);
    canvas.drawLine(Offset(0, -size), Offset(0, size), vp);
  }

  @override
  bool shouldRepaint(_LeafPainter o) => o.time != time;
}

// ── Виджет ────────────────────────────────────────────────────────────────────
class ClassicBackground extends StatefulWidget {
  const ClassicBackground({Key? key}) : super(key: key);

  @override
  State<ClassicBackground> createState() => _ClassicBackgroundState();
}

class _ClassicBackgroundState extends State<ClassicBackground>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late List<_Leaf> _leaves;
  final _rng = math.Random();
  double _time = 0;

  // Осенние цвета листьев — приглушённые, тёмные (на тёмном фоне)
  static const _leafColors = [
    Color(0xFF4CAF50),  // зелёный
    Color(0xFF81C784),  // светло-зелёный
    Color(0xFF2E7D32),  // тёмно-зелёный
    Color(0xFF66BB6A),  // средне-зелёный
    Color(0xFFA5D6A7),  // бледно-зелёный
    Color(0xFF558B2F),  // оливковый
    Color(0xFF80CBC4),  // мятный
    Color(0xFF26A69A),  // бирюзовый
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _ctrl.addListener(_update);
    _leaves = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _spawnInitial();
    });
  }

  void _spawnInitial() {
    final size = context.size ?? const Size(400, 800);
    for (int i = 0; i < 35; i++) {
      _leaves.add(_createLeaf(size, randomY: true));
    }
  }

  _Leaf _createLeaf(Size size, {bool randomY = false}) {
    final shapes = _LeafShape.values;
    final shape = shapes[_rng.nextInt(shapes.length)];
    final leafSize = 5.0 + _rng.nextDouble() * 10;

    return _Leaf(
      x: _rng.nextDouble() * (size.width + 40) - 20,
      y: randomY
          ? _rng.nextDouble() * size.height
          : -20 - _rng.nextDouble() * 50,
      vx: (_rng.nextDouble() - 0.5) * 0.4,
      vy: 0.14 + _rng.nextDouble() * 0.28, // медленно падает
      size: leafSize,
      alpha: 0.25 + _rng.nextDouble() * 0.45,
      rotation: _rng.nextDouble() * math.pi * 2,
      rotSpeed: (_rng.nextDouble() - 0.5) * 0.025, // плавное вращение
      swayPhase: _rng.nextDouble() * math.pi * 2,
      swayAmp: 0.3 + _rng.nextDouble() * 0.7,
      shape: shape,
      color: _leafColors[_rng.nextInt(_leafColors.length)],
    );
  }

  void _update() {
    if (!mounted) return;
    final size = context.size ?? const Size(400, 800);
    _time += 0.016;

    setState(() {
      for (final leaf in _leaves) {
        // Покачивание — синусоидальный дрейф
        leaf.swayPhase += 0.018;
        leaf.x += leaf.vx + math.sin(leaf.swayPhase) * leaf.swayAmp * 0.3;
        leaf.y += leaf.vy;
        leaf.rotation += leaf.rotSpeed;

        // Листья у края экрана чуть прозрачнее
        if (leaf.y > size.height * 0.85) {
          leaf.alpha -= 0.004;
        }
      }

      // Убираем упавшие/улетевшие
      _leaves.removeWhere((l) =>
      l.alpha <= 0.02 ||
          l.y > size.height + 30 ||
          l.x < -60 ||
          l.x > size.width + 60);

      // Спавним новые сверху
      while (_leaves.length < 38) {
        _leaves.add(_createLeaf(size));
      }
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_update);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LeafPainter(leaves: _leaves, time: _time),
      child: const SizedBox.expand(),
    );
  }
}