import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/app_localizations.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Данные стрелки
// ──────────────────────────────────────────────────────────────────────────────
class _Arrow {
  final int fromRow, fromCol, toRow, toCol;
  final Color color;
  const _Arrow({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    required this.color,
  });
}

// ──────────────────────────────────────────────────────────────────────────────
// Один шаг туториала
// ──────────────────────────────────────────────────────────────────────────────
class _TutStep {
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) desc;
  // boardBuilder получает анимационное значение 0..1
  final Widget Function(double anim) boardBuilder;

  const _TutStep({
    required this.title,
    required this.desc,
    required this.boardBuilder,
  });
}

// ──────────────────────────────────────────────────────────────────────────────
// Экран туториала
// ──────────────────────────────────────────────────────────────────────────────
class TutorialScreen extends StatefulWidget {
  final AppLocalizations loc;
  const TutorialScreen({Key? key, required this.loc}) : super(key: key);

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = _step + delta;
    if (next < 0) return;
    if (next >= _steps.length) {
      Navigator.pop(context);
      return;
    }
    setState(() => _step = next);
    _ctrl
      ..reset()
      ..repeat(reverse: true);
  }

  // ── Описания всех шагов ────────────────────────────────────────────────────
  List<_TutStep> get _steps => [
    // 1. Начальная позиция
    _TutStep(
      title: (l) => l.tutStep1Title,
      desc: (l) => l.tutStep1Desc,
      boardBuilder: (_) => _board4(
        pieces: const {
          (1, 1): Player.white,
          (1, 2): Player.black,
          (2, 1): Player.black,
          (2, 2): Player.white,
        },
      ),
    ),

    // 2. Допустимые ходы — правильные позиции
    _TutStep(
      title: (l) => l.tutStep2Title,
      desc: (l) => l.tutStep2Desc,
      boardBuilder: (a) => _board4(
        pieces: const {
          (1, 1): Player.white,
          (1, 2): Player.black,
          (2, 1): Player.black,
          (2, 2): Player.white,
        },
        // (1,0): чёрная зажимает (1,1)белую → (1,2)чёрная
        // (0,1): чёрная зажимает (1,1)белую → (2,1)чёрная
        // (2,3): чёрная зажимает (2,2)белую → (2,1)чёрная
        // (3,2): чёрная зажимает (2,2)белую → (1,2)чёрная
        hints: const [(1, 0), (0, 1), (2, 3), (3, 2)],
        hintOpacity: 0.8 + 0.2 * a,
      ),
    ),

    // 3. Ход — красная стрелка, ставим на (1,0) зажимая (1,1)белую
    _TutStep(
      title: (l) => l.tutStep3Title,
      desc: (l) => l.tutStep3Desc,
      boardBuilder: (a) => _board4(
        pieces: const {
          (1, 1): Player.white,
          (1, 2): Player.black,
          (2, 1): Player.black,
          (2, 2): Player.white,
        },
        hints: const [(1, 0)],
        hintOpacity: 0.8 + 0.2 * a,
        arrows: const [
          _Arrow(
              fromRow: 1,
              fromCol: 2,
              toRow: 1,
              toCol: 0,
              color: Color(0xFFE74C3C)),
        ],
      ),
    ),

    // 4. Фишка поставлена на (1,0), переворачивается (1,1)
    _TutStep(
      title: (l) => l.tutStep4Title,
      desc: (l) => l.tutStep4Desc,
      boardBuilder: (a) => _board4(
        pieces: const {
          (1, 2): Player.black,
          (2, 1): Player.black,
          (2, 2): Player.white,
        },
        newPiece: (1, 0, Player.black),
        flipPieces: const [(1, 1)],
        flipProgress: a,
        flipFromPlayer: Player.white,
        flipToPlayer: Player.black,
      ),
    ),

    // 5. Результат — (1,1) теперь чёрная
    _TutStep(
      title: (l) => l.tutStep5Title,
      desc: (l) => l.tutStep5Desc,
      boardBuilder: (_) => _board4(
        pieces: const {
          (1, 0): Player.black,
          (1, 1): Player.black,  // перевёрнутая
          (1, 2): Player.black,
          (2, 1): Player.black,
          (2, 2): Player.white,
        },
        glowPiece: (1, 1),
      ),
    ),

    // 6. Диагональный захват — ставим в (0,0), якорь в (3,3), стрелка снизу-справа вверх-влево
    _TutStep(
      title: (l) => l.tutStep6Title,
      desc: (l) => l.tutStep6Desc,
      boardBuilder: (a) => _board5(
        pieces: const {
          (1, 1): Player.white,
          (2, 2): Player.white,
          (3, 3): Player.black,  // якорная чёрная
        },
        hints: const [(0, 0)],   // сюда ставим новую чёрную
        hintOpacity: 0.8 + 0.2 * a,
        arrows: const [
          _Arrow(
              fromRow: 3,      // от якоря снизу-справа
              fromCol: 3,
              toRow: 0,        // к новой фишке вверху-слева
              toCol: 0,
              color: Color(0xFFE74C3C)),
        ],
      ),
    ),

    // 7. Стратегия — углы
    _TutStep(
      title: (l) => l.tutStep7Title,
      desc: (l) => l.tutStep7Desc,
      boardBuilder: (a) => _board4(
        pieces: const {
          (1, 1): Player.white,
          (1, 2): Player.black,
          (2, 1): Player.black,
          (2, 2): Player.white,
        },
        cornerStars: true,
        hintOpacity: 0.4 + 0.5 * a,
      ),
    ),
  ];

  // ── Хелперы создания досок ─────────────────────────────────────────────────
  Widget _board4({
    Map<(int, int), Player> pieces = const {},
    List<(int, int)> hints = const [],
    double hintOpacity = 0.6,
    List<_Arrow> arrows = const [],
    (int, int, Player)? newPiece,
    List<(int, int)> flipPieces = const [],
    double flipProgress = 0.0,
    Player flipFromPlayer = Player.white,
    Player flipToPlayer = Player.black,
    (int, int)? glowPiece,
    bool cornerStars = false,
  }) =>
      _BoardWidget(
        size: 4,
        pieces: pieces,
        hints: hints,
        hintOpacity: hintOpacity,
        arrows: arrows,
        newPiece: newPiece,
        flipPieces: flipPieces,
        flipProgress: flipProgress,
        flipFromPlayer: flipFromPlayer,
        flipToPlayer: flipToPlayer,
        glowPiece: glowPiece,
        cornerStars: cornerStars,
      );

  Widget _board5({
    Map<(int, int), Player> pieces = const {},
    List<(int, int)> hints = const [],
    double hintOpacity = 0.6,
    List<_Arrow> arrows = const [],
  }) =>
      _BoardWidget(
        size: 5,
        pieces: pieces,
        hints: hints,
        hintOpacity: hintOpacity,
        arrows: arrows,
      );

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final loc = widget.loc;
    final step = _steps[_step];
    final isLast = _step == _steps.length - 1;

    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(loc.rulesTitle,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // прогресс-бар
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 2),
              child: Row(
                children: List.generate(_steps.length, (i) {
                  final active = i == _step;
                  final done = i < _step;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white
                            : done
                            ? GameConstants.boardColor
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Text('${_step + 1} / ${_steps.length}',
                style:
                const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 4),

            // доска
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (_, __) => step.boardBuilder(_anim.value),
                    ),
                  ),
                ),
              ),
            ),

            // текст
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      step.title(loc),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      step.desc(loc),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14, height: 1.55),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // кнопки
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Row(
                children: [
                  if (_step > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _go(-1),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(loc.tutBack),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _go(1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLast
                            ? GameConstants.boardColor
                            : Colors.white.withOpacity(0.14),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isLast ? loc.gotIt : loc.tutNext,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Widget-обёртка вокруг CustomPainter
// ──────────────────────────────────────────────────────────────────────────────
class _BoardWidget extends StatelessWidget {
  final int size;
  final Map<(int, int), Player> pieces;
  final List<(int, int)> hints;
  final double hintOpacity;
  final List<_Arrow> arrows;
  final (int, int, Player)? newPiece;
  final List<(int, int)> flipPieces;
  final double flipProgress;
  final Player flipFromPlayer;
  final Player flipToPlayer;
  final (int, int)? glowPiece;
  final bool cornerStars;

  const _BoardWidget({
    required this.size,
    this.pieces = const {},
    this.hints = const [],
    this.hintOpacity = 0.6,
    this.arrows = const [],
    this.newPiece,
    this.flipPieces = const [],
    this.flipProgress = 0.0,
    this.flipFromPlayer = Player.white,
    this.flipToPlayer = Player.black,
    this.glowPiece,
    this.cornerStars = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BoardPainter(
        size: size,
        pieces: pieces,
        hints: hints,
        hintOpacity: hintOpacity,
        arrows: arrows,
        newPiece: newPiece,
        flipPieces: flipPieces,
        flipProgress: flipProgress,
        flipFromPlayer: flipFromPlayer,
        flipToPlayer: flipToPlayer,
        glowPiece: glowPiece,
        cornerStars: cornerStars,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Painter
// ──────────────────────────────────────────────────────────────────────────────
class _BoardPainter extends CustomPainter {
  final int size;
  final Map<(int, int), Player> pieces;
  final List<(int, int)> hints;
  final double hintOpacity;
  final List<_Arrow> arrows;
  final (int, int, Player)? newPiece;
  final List<(int, int)> flipPieces;
  final double flipProgress;
  final Player flipFromPlayer;
  final Player flipToPlayer;
  final (int, int)? glowPiece;
  final bool cornerStars;

  _BoardPainter({
    required this.size,
    required this.pieces,
    required this.hints,
    required this.hintOpacity,
    required this.arrows,
    required this.newPiece,
    required this.flipPieces,
    required this.flipProgress,
    required this.flipFromPlayer,
    required this.flipToPlayer,
    required this.glowPiece,
    required this.cornerStars,
  });

  @override
  void paint(Canvas canvas, Size cs) {
    final cell = cs.width / size;

    // Фон
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, cs.width, cs.height),
            const Radius.circular(18)),
        Paint()..color = const Color(0xFF1A6B3C));

    // Ячейки
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final rect = _cell(r, c, cell);
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)),
            Paint()..color = const Color(0xFF27AE60));
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)),
            Paint()
              ..color = const Color(0xFF1A7A3C)
              ..strokeWidth = 0.7
              ..style = PaintingStyle.stroke);
      }
    }

    // Подсветки — жёлтые точки
    for (final h in hints) {
      final rect = _cell(h.$1, h.$2, cell);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()
            ..color =
            const Color(0xFFF1C40F).withOpacity(hintOpacity * 0.4));
      canvas.drawCircle(
          rect.center,
          cell * 0.22,
          Paint()
            ..color =
            const Color(0xFFF1C40F).withOpacity(hintOpacity));
    }

    // Звёзды в углах
    if (cornerStars) {
      final p = Paint()..color = const Color(0xFFF1C40F);
      for (final pos in [
        (0, 0),
        (0, size - 1),
        (size - 1, 0),
        (size - 1, size - 1)
      ]) {
        _star(canvas, _cell(pos.$1, pos.$2, cell).center, cell * 0.27, p);
      }
    }

    // Стрелки (рисуем до фишек)
    for (final a in arrows) {
      _drawArrow(canvas, a, cell);
    }

    // Собираем все фишки
    final all = Map<(int, int), Player>.from(pieces);
    if (newPiece != null) {
      all[(newPiece!.$1, newPiece!.$2)] = newPiece!.$3;
    }

    all.forEach((pos, player) {
      final rect = _cell(pos.$1, pos.$2, cell);
      final isFlip = flipPieces.contains(pos);
      final isGlow = glowPiece != null &&
          glowPiece!.$1 == pos.$1 &&
          glowPiece!.$2 == pos.$2;

      if (isGlow) {
        canvas.drawCircle(
            rect.center,
            cell * 0.42,
            Paint()
              ..color = const Color(0xFF2ECC71).withOpacity(0.5)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      }

      if (isFlip) {
        final sx = flipProgress < 0.5
            ? 1.0 - flipProgress * 2.0
            : (flipProgress - 0.5) * 2.0;
        final displayPlayer =
        flipProgress < 0.5 ? flipFromPlayer : flipToPlayer;
        _piece(canvas, rect.center, cell * 0.38, displayPlayer, sx);
      } else {
        _piece(canvas, rect.center, cell * 0.38, player, 1.0);
      }
    });

    // Обводка новой фишки
    if (newPiece != null) {
      canvas.drawCircle(
          _cell(newPiece!.$1, newPiece!.$2, cell).center,
          cell * 0.4,
          Paint()
            ..color = const Color(0xFF2ECC71)
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke);
    }
  }

  Rect _cell(int r, int c, double cell) {
    const p = 3.5;
    return Rect.fromLTWH(c * cell + p, r * cell + p,
        cell - p * 2, cell - p * 2);
  }

  void _piece(Canvas canvas, Offset center, double r, Player player,
      double sx) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(sx, 1.0);
    canvas.translate(-center.dx, -center.dy);

    final isBlack = player == Player.black;

    // тень
    canvas.drawCircle(
        center + const Offset(2, 3),
        r,
        Paint()..color = Colors.black.withOpacity(0.35));

    // тело
    canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0.3, 0.4),
            radius: 0.85,
            colors: isBlack
                ? [const Color(0xFF1A1A1A), Colors.black]
                : [Colors.white, const Color(0xFFBDC3C7)],
          ).createShader(
              Rect.fromCircle(center: center, radius: r)));

    // блик
    canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.4, -0.4),
            radius: 0.5,
            colors: [
              Colors.white.withOpacity(isBlack ? 0.22 : 0.72),
              Colors.transparent,
            ],
          ).createShader(
              Rect.fromCircle(center: center, radius: r)));

    canvas.restore();
  }

  void _drawArrow(Canvas canvas, _Arrow a, double cell) {
    final from = _cell(a.fromRow, a.fromCol, cell).center;
    final to = _cell(a.toRow, a.toCol, cell).center;
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    final ux = dx / len;
    final uy = dy / len;

    final start = Offset(from.dx + ux * cell * 0.42,
        from.dy + uy * cell * 0.42);
    final end = Offset(to.dx - ux * cell * 0.44,
        to.dy - uy * cell * 0.44);

    final paint = Paint()
      ..color = a.color.withOpacity(0.92)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);

    // наконечник
    final angle = math.atan2(dy, dx);
    const hl = 13.0;
    const ha = 0.44;
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - hl * math.cos(angle - ha),
          end.dy - hl * math.sin(angle - ha))
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - hl * math.cos(angle + ha),
          end.dy - hl * math.sin(angle + ha));
    canvas.drawPath(path, paint);
  }

  void _star(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final oa = i * 4 * math.pi / 5 - math.pi / 2;
      final ia = oa + 2 * math.pi / 5;
      final op = Offset(c.dx + r * math.cos(oa), c.dy + r * math.sin(oa));
      final ip =
      Offset(c.dx + r * 0.42 * math.cos(ia), c.dy + r * 0.42 * math.sin(ia));
      i == 0 ? path.moveTo(op.dx, op.dy) : path.lineTo(op.dx, op.dy);
      path.lineTo(ip.dx, ip.dy);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_BoardPainter o) =>
      o.flipProgress != flipProgress || o.hintOpacity != hintOpacity;
}