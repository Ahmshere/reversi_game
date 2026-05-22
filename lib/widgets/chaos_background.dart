import 'dart:math' as math;
import 'package:flutter/material.dart';

// ── Частица (камень/искра/жар) ───────────────────────────────────────────────
class _Ember {
  double x, y;          // позиция
  double vx, vy;        // скорость
  double size;          // размер
  double alpha;         // прозрачность
  double rotation;
  double rotSpeed;
  final _EmberType type;
  final Color color;

  _Ember({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.alpha,
    required this.rotation,
    required this.rotSpeed,
    required this.type,
    required this.color,
  });
}

enum _EmberType { spark, rock, glow }

// ── Painter ───────────────────────────────────────────────────────────────────
class _FirePainter extends CustomPainter {
  final List<_Ember> embers;
  final double time;

  const _FirePainter({required this.embers, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // Фоновый градиент лавы — снизу вверх
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0A0010).withOpacity(0.95),
          const Color(0xFF1A0500).withOpacity(0.92),
          const Color(0xFF3D0800).withOpacity(0.88),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Пульсирующие зарева снизу
    for (int i = 0; i < 3; i++) {
      final cx = size.width * (0.2 + i * 0.3);
      final cy = size.height * 0.92;
      final pulse = 0.5 + 0.5 * math.sin(time * 1.2 + i * 2.1);
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFF4500).withOpacity(0.35 * pulse),
            const Color(0xFFFF6B00).withOpacity(0.15 * pulse),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(cx, cy),
          radius: size.width * (0.3 + 0.1 * pulse),
        ));
      canvas.drawCircle(
          Offset(cx, cy), size.width * (0.3 + 0.1 * pulse), glowPaint);
    }

    // Боковые отсветы
    final leftGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFAA2200)
              .withOpacity(0.3 + 0.1 * math.sin(time * 0.8)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(0, size.height * 0.7),
        radius: size.width * 0.5,
      ));
    canvas.drawCircle(
        Offset(0, size.height * 0.7), size.width * 0.5, leftGlow);

    final rightGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFCC3300)
              .withOpacity(0.25 + 0.1 * math.sin(time * 1.1)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width, size.height * 0.6),
        radius: size.width * 0.5,
      ));
    canvas.drawCircle(
        Offset(size.width, size.height * 0.6), size.width * 0.5, rightGlow);

    // Рисуем частицы
    for (final e in embers) {
      final paint = Paint()..color = e.color.withOpacity(e.alpha);

      canvas.save();
      canvas.translate(e.x, e.y);
      canvas.rotate(e.rotation);

      switch (e.type) {
        case _EmberType.rock:
        // Камень — неровный многоугольник
          final path = Path();
          final sides = 5 + (e.size ~/ 4);
          for (int i = 0; i < sides; i++) {
            final angle = i * math.pi * 2 / sides;
            final r = e.size * (0.7 + 0.3 * math.sin(angle * 3 + e.rotation));
            final px = math.cos(angle) * r;
            final py = math.sin(angle) * r;
            if (i == 0) path.moveTo(px, py); else path.lineTo(px, py);
          }
          path.close();
          canvas.drawPath(path, paint);
          // Лавовое свечение внутри камня
          final glowPaint = Paint()
            ..color = const Color(0xFFFF4500).withOpacity(e.alpha * 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
          canvas.drawCircle(Offset.zero, e.size * 0.4, glowPaint);
          break;

        case _EmberType.spark:
        // Искра — яркая точка с хвостом
          final sparkPaint = Paint()
            ..color = e.color.withOpacity(e.alpha)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, e.size * 0.8);
          canvas.drawCircle(Offset.zero, e.size, sparkPaint);
          canvas.drawCircle(
              Offset.zero,
              e.size * 0.4,
              Paint()..color = Colors.white.withOpacity(e.alpha * 0.9));
          break;

        case _EmberType.glow:
        // Мягкое свечение
          final glowPaint2 = Paint()
            ..color = e.color.withOpacity(e.alpha * 0.6)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, e.size);
          canvas.drawCircle(Offset.zero, e.size, glowPaint2);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FirePainter o) => o.time != time;
}

// ── Виджет ────────────────────────────────────────────────────────────────────
class ChaosBackground extends StatefulWidget {
  const ChaosBackground({Key? key}) : super(key: key);

  @override
  State<ChaosBackground> createState() => _ChaosBackgroundState();
}

class _ChaosBackgroundState extends State<ChaosBackground>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late List<_Ember> _embers;
  final _rng = math.Random();
  double _time = 0;

  // Цвета камней и искр
  static const _rockColors = [
    Color(0xFF8B1A00),
    Color(0xFFAA2200),
    Color(0xFF6B3A2A),
    Color(0xFF5C2A1A),
    Color(0xFF3D1A0A),
  ];
  static const _sparkColors = [
    Color(0xFFFFCC00),
    Color(0xFFFF8800),
    Color(0xFFFF4400),
    Color(0xFFFFEE88),
    Color(0xFFFFAA00),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _ctrl.addListener(_update);
    _embers = [];
    // Спавним начальные частицы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _spawnInitial();
    });
  }

  void _spawnInitial() {
    final size = context.size ?? const Size(400, 800);
    for (int i = 0; i < 60; i++) {
      _embers.add(_createEmber(size, randomY: true));
    }
  }

  _Ember _createEmber(Size size, {bool randomY = false}) {
    final isRock = _rng.nextDouble() < 0.3;
    final isGlow = !isRock && _rng.nextDouble() < 0.3;
    final type = isRock
        ? _EmberType.rock
        : isGlow
        ? _EmberType.glow
        : _EmberType.spark;

    // Спавн внизу или сбоку
    final spawnSide = _rng.nextDouble();
    double x, y;
    double vx, vy;

    if (spawnSide < 0.6) {
      // Снизу — летит вверх
      x = _rng.nextDouble() * size.width;
      y = randomY ? _rng.nextDouble() * size.height : size.height + 20;
      vx = (_rng.nextDouble() - 0.5) * 1.5;
      vy = -(1.5 + _rng.nextDouble() * 3.5);
    } else if (spawnSide < 0.8) {
      // Слева
      x = -20;
      y = randomY
          ? _rng.nextDouble() * size.height
          : size.height * (0.5 + _rng.nextDouble() * 0.5);
      vx = 1 + _rng.nextDouble() * 2;
      vy = -(0.5 + _rng.nextDouble() * 2);
    } else {
      // Справа
      x = size.width + 20;
      y = randomY
          ? _rng.nextDouble() * size.height
          : size.height * (0.5 + _rng.nextDouble() * 0.5);
      vx = -(1 + _rng.nextDouble() * 2);
      vy = -(0.5 + _rng.nextDouble() * 2);
    }

    final size_ = type == _EmberType.rock
        ? 4.0 + _rng.nextDouble() * 10
        : type == _EmberType.glow
        ? 8.0 + _rng.nextDouble() * 16
        : 2.0 + _rng.nextDouble() * 5;

    return _Ember(
      x: x,
      y: y,
      vx: vx,
      vy: vy,
      size: size_,
      alpha: 0.4 + _rng.nextDouble() * 0.6,
      rotation: _rng.nextDouble() * math.pi * 2,
      rotSpeed: (_rng.nextDouble() - 0.5) * 0.08,
      type: type,
      color: type == _EmberType.rock
          ? _rockColors[_rng.nextInt(_rockColors.length)]
          : _sparkColors[_rng.nextInt(_sparkColors.length)],
    );
  }

  void _update() {
    if (!mounted) return;
    final size = context.size ?? const Size(400, 800);
    _time += 0.016;

    setState(() {
      // Двигаем частицы — скорость вдвое меньше
      for (final e in _embers) {
        e.x += e.vx * 0.5;
        e.y += e.vy * 0.5;
        e.vy += 0.02; // гравитация мягче
        e.vx += (_rng.nextDouble() - 0.5) * 0.025;
        e.rotation += e.rotSpeed * 0.5;
        // Угасание в верхней части
        if (e.y < size.height * 0.3) {
          e.alpha -= 0.008;
        }
      }

      // Удаляем улетевшие/погасшие
      _embers.removeWhere((e) =>
      e.alpha <= 0 ||
          e.y > size.height + 30 ||
          e.x < -50 ||
          e.x > size.width + 50);

      // Спавним новые
      while (_embers.length < 65) {
        _embers.add(_createEmber(size));
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
      painter: _FirePainter(embers: _embers, time: _time),
      child: const SizedBox.expand(),
    );
  }
}