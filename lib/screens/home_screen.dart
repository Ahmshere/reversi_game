import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/game_state.dart';
import 'game_stats.dart';
import 'achievements_screen.dart';
import '../utils/constants.dart';
import '../utils/board_theme.dart';
import '../utils/audio_service.dart';
import '../utils/app_localizations.dart';
import '../utils/settings_service.dart';
import '../version.dart';
import 'game_screen.dart';
import 'mode_select_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'tutorial_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Данные парящей фишки
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingPiece {
  double x, y, size, speed, angle, rotationSpeed, opacity;
  // Дополнительные осцилляторы с иррациональными частотами — движение не повторяется
  double speed2, angle2, speedX, angleX;
  bool isBlack;

  _FloatingPiece({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.rotationSpeed,
    required this.opacity,
    required this.speed2,
    required this.angle2,
    required this.speedX,
    required this.angleX,
    required this.isBlack,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter для анимированного фона
// ─────────────────────────────────────────────────────────────────────────────
// ── Данные одного взрыва на главном экране ────────────────────────────────────
class _HomeBurst {
  final double x, y;    // позиция (0..1)
  final double startT;  // время запуска
  final double duration;
  final List<Color> colors;

  const _HomeBurst({
    required this.x, required this.y,
    required this.startT, required this.duration,
    required this.colors,
  });
}

class _BackgroundPainter extends CustomPainter {
  final List<_FloatingPiece> pieces;
  final double time;
  final List<_HomeBurst> bursts;

  _BackgroundPainter({
    required this.pieces,
    required this.time,
    this.bursts = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0D1B2A),
          Color(0xFF1A1035),
          Color(0xFF0A1628),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    _drawGlowOrb(canvas, Offset(size.width * 0.15, size.height * 0.25),
        130, const Color(0xFF27AE60), 0.07);
    _drawGlowOrb(canvas, Offset(size.width * 0.85, size.height * 0.65),
        100, const Color(0xFF8E44AD), 0.06);
    _drawGlowOrb(canvas, Offset(size.width * 0.5, size.height * 0.1),
        80, const Color(0xFF2980B9), 0.05);

    // ── Взрывы ────────────────────────────────────────────────────────────
    for (final burst in bursts) {
      final elapsed = time - burst.startT;
      if (elapsed < 0 || elapsed > burst.duration) continue;
      final p = (elapsed / burst.duration).clamp(0.0, 1.0);
      _drawBurst(canvas, size, burst, p);
    }

    // ── Парящие фишки ─────────────────────────────────────────────────────
    for (final p in pieces) {
      final dy = math.sin(time * p.speed + p.angle) * 0.028
          + math.sin(time * p.speed2 + p.angle2) * 0.016;
      final dx = math.sin(time * p.speedX + p.angleX) * 0.012
          + math.cos(time * p.speed * 0.7071 + p.angle) * 0.008;
      final px = (p.x + dx) * size.width;
      final py = (p.y + dy) * size.height;
      final r = p.size;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(time * p.rotationSpeed);

      canvas.drawCircle(
        const Offset(2, 3),
        r,
        Paint()..color = Colors.black.withOpacity(p.opacity * 0.4),
      );

      final colors = p.isBlack
          ? [const Color(0xFF2D2D2D), const Color(0xFF111111)]
          : [const Color(0xFFECF0F1), const Color(0xFFBDC3C7)];

      canvas.drawCircle(
        Offset.zero,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0.3, 0.3),
            radius: 0.85,
            colors: colors,
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)),
      );

      canvas.drawCircle(
        Offset(-r * 0.3, -r * 0.3),
        r * 0.35,
        Paint()
          ..color = Colors.white.withOpacity(
            (p.isBlack ? 0.12 : 0.45) * p.opacity,
          ),
      );

      canvas.restore();
    }
  }

  void _drawBurst(Canvas canvas, Size size, _HomeBurst burst, double p) {
    final cx = burst.x * size.width;
    final cy = burst.y * size.height;
    final eased = Curves.easeOut.transform(p);

    // Ударная волна
    for (int i = 0; i < burst.colors.length; i++) {
      final delay = i * 0.12;
      final wp = ((p - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (wp <= 0) continue;
      final wEased = Curves.easeOut.transform(wp);
      canvas.drawCircle(
        Offset(cx, cy),
        wEased * (55 + i * 18),
        Paint()
          ..color = burst.colors[i].withOpacity((1 - wp) * 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * (1 - wp),
      );
    }

    // Вспышка
    if (p < 0.35) {
      final flashA = (1 - p / 0.35) * 0.25;
      canvas.drawCircle(
        Offset(cx, cy),
        35 * (1 - p * 0.5),
        Paint()
          ..shader = RadialGradient(colors: [
            burst.colors[0].withOpacity(flashA),
            Colors.transparent,
          ]).createShader(Rect.fromCircle(
              center: Offset(cx, cy), radius: 35)),
      );
    }

    // Частицы
    final rng = math.Random(burst.startT.toInt() * 1000 + burst.x.toInt());
    for (int i = 0; i < 16; i++) {
      final angle = i * math.pi * 2 / 16 + rng.nextDouble() * 0.4;
      final speed = 28 + rng.nextDouble() * 32;
      final dist = eased * speed;
      final px2 = cx + math.cos(angle) * dist;
      final py2 = cy + math.sin(angle) * dist;
      final alpha = (1 - eased).clamp(0.0, 1.0) * 0.55;
      final r = 2.5 + rng.nextDouble() * 3;
      canvas.drawCircle(
        Offset(px2, py2),
        r * (1 - eased * 0.6),
        Paint()
          ..color = burst.colors[i % burst.colors.length].withOpacity(alpha),
      );
    }

    // Искры
    final sparkPaint = Paint()..strokeWidth = 1.5;
    for (int i = 0; i < 10; i++) {
      final a = i * math.pi * 2 / 10 + 0.3;
      final len = 12 + 20 * eased;
      final alpha = (1 - eased * 1.4).clamp(0.0, 1.0) * 0.5;
      sparkPaint.color = burst.colors[0].withOpacity(alpha);
      canvas.drawLine(
        Offset(cx + math.cos(a) * 8, cy + math.sin(a) * 8),
        Offset(cx + math.cos(a) * len, cy + math.sin(a) * len),
        sparkPaint,
      );
    }
  }

  void _drawGlowOrb(Canvas canvas, Offset center, double r, Color color,
      double opacity) {
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = color.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter o) =>
      o.time != time || o.bursts.length != bursts.length;
}

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  BoardTheme _selectedTheme = SettingsService().boardTheme;
  final AudioService _audio = AudioService();
  AppLanguage _language = SettingsService().language;

  late Ticker _ticker;
  double _time = 0.0;
  double _lastBurstTime = 0.0; // когда был последний взрыв
  final List<_HomeBurst> _bursts = [];
  final _rng = math.Random();

  // Палитры для взрывов — разные цвета каждый раз
  static const _burstPalettes = [
    [Color(0xFF27AE60), Color(0xFF56E39F), Color(0xFF1DB954)],
    [Color(0xFF8E44AD), Color(0xFFAA00FF), Color(0xFFE040FB)],
    [Color(0xFF2980B9), Color(0xFF00E5FF), Color(0xFF5DADE2)],
    [Color(0xFFFF6B35), Color(0xFFFF1744), Color(0xFFFFCC00)],
    [Color(0xFF27AE60), Color(0xFF2980B9), Color(0xFF8E44AD)],
  ];

  // Ticker накапливает время монотонно — никогда не сбрасывается, нет рывков


  late AnimationController _entranceController;
  late Animation<double> _titleAnim;
  late Animation<double> _card1Anim;
  late Animation<double> _card2Anim;
  late Animation<double> _bottomAnim;

  late List<_FloatingPiece> _pieces;

  AppLocalizations get _loc => AppLocalizations(_language);

  @override
  void initState() {
    super.initState();

    // Ticker накапливает время монотонно — никогда не сбрасывается, нет рывков
    _ticker = createTicker((elapsed) {
      final t = elapsed.inMilliseconds / 1000.0;
      // Редкий спавн взрыва: каждые 8–15 секунд случайно
      final timeSinceLast = t - _lastBurstTime;
      if (timeSinceLast > 8 &&
          _rng.nextDouble() < 0.004) { // ~0.4% каждый кадр
        _spawnBurst(t);
        _lastBurstTime = t;
      }
      // Убираем завершённые взрывы
      _bursts.removeWhere((b) => t - b.startT > b.duration + 0.5);
      setState(() => _time = t);
    })..start();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _titleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    );
    _card1Anim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic),
    );
    _card2Anim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
    );
    _bottomAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
    );

    _pieces = _generatePieces();
  }

  List<_FloatingPiece> _generatePieces() {
    final rng = math.Random(42);
    return List.generate(14, (i) {
      final baseSpeed = 0.25 + rng.nextDouble() * 0.45;
      return _FloatingPiece(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: 8 + rng.nextDouble() * 18,
        speed: baseSpeed,
        angle: rng.nextDouble() * math.pi * 2,
        // √2 ≈ 1.4142 — иррационально к 1, суперпозиция не повторяется
        speed2: baseSpeed * (1.4142 + rng.nextDouble() * 0.3),
        angle2: rng.nextDouble() * math.pi * 2,
        // √3 ≈ 1.7320 — третья несоизмеримая частота для X
        speedX: baseSpeed * (1.7320 + rng.nextDouble() * 0.25),
        angleX: rng.nextDouble() * math.pi * 2,
        rotationSpeed: (rng.nextDouble() - 0.5) * 0.35,
        opacity: 0.06 + rng.nextDouble() * 0.1,
        isBlack: i.isEven,
      );
    });
  }

  void _spawnBurst(double t) {
    final palette = _burstPalettes[_rng.nextInt(_burstPalettes.length)];
    _bursts.add(_HomeBurst(
      x: 0.1 + _rng.nextDouble() * 0.8,
      y: 0.1 + _rng.nextDouble() * 0.7,
      startT: t,
      duration: 2.2 + _rng.nextDouble() * 1.0,
      colors: palette,
    ));
  }

  @override
  void dispose() {
    _ticker.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = _loc;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          // Анимированный фон
          CustomPaint(
            painter: _BackgroundPainter(
              pieces: _pieces,
              time: _time,
              bursts: _bursts,
            ),
            child: const SizedBox.expand(),
          ),

          // UI контент
          SafeArea(
            child: Column(
              children: [
                // Кнопка настроек
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.emoji_events_outlined,
                              color: Colors.white54, size: 26),
                          onPressed: () => _showAchievements(context),
                          tooltip: _loc.achievementsTitle,
                        ),
                        IconButton(
                          icon: const Icon(Icons.bar_chart_rounded,
                              color: Colors.white54, size: 26),
                          onPressed: () => _showStats(context),
                          tooltip: _loc.statsTitle,
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined,
                              color: Colors.white54, size: 26),
                          onPressed: () => _showSettings(context),
                          tooltip: _loc.settings,
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.07,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.02),

                        // Логотип с анимированными фишками
                        FadeTransition(
                          opacity: _titleAnim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, -0.3),
                              end: Offset.zero,
                            ).animate(_titleAnim),
                            child: _buildLogoArea(),
                          ),
                        ),

                        SizedBox(height: size.height * 0.03),

                        // Заголовок
                        FadeTransition(
                          opacity: _titleAnim,
                          child: _buildTitle(loc),
                        ),

                        SizedBox(height: size.height * 0.05),

                        // VS PLAYER
                        FadeTransition(
                          opacity: _card1Anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-0.15, 0),
                              end: Offset.zero,
                            ).animate(_card1Anim),
                            child: _buildPrimaryButton(
                              label: loc.vsPlayer,
                              icon: Icons.people_alt_rounded,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1DB954), Color(0xFF0D7A3A)],
                              ),
                              glowColor: const Color(0xFF1DB954),
                              onPressed: () => _startGame(context, GameMode.vsPlayer),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // VS COMPUTER
                        FadeTransition(
                          opacity: _card2Anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.15, 0),
                              end: Offset.zero,
                            ).animate(_card2Anim),
                            child: _buildPrimaryButton(
                              label: loc.vsComputer,
                              icon: Icons.smart_toy_rounded,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF7C6CF2), Color(0xFF4A38CC)],
                              ),
                              glowColor: const Color(0xFF7C6CF2),
                              onPressed: () => _startGame(context, GameMode.vsAI),
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.022),

                        // CHAOS MODE — разделитель
                        FadeTransition(
                          opacity: _bottomAnim,
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                    color: Colors.white.withOpacity(0.1),
                                    thickness: 0.5),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  '*',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 11,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                    color: Colors.white.withOpacity(0.1),
                                    thickness: 0.5),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 0.022),

                        // CHAOS MODE кнопка
                        FadeTransition(
                          opacity: _bottomAnim,
                          child: _buildChaosButton(context),
                        ),

                        SizedBox(height: size.height * 0.045),

                        // Как играть + Версия
                        FadeTransition(
                          opacity: _bottomAnim,
                          child: Column(
                            children: [
                              _buildTextButton(
                                label: loc.howToPlay,
                                icon: Icons.menu_book_rounded,
                                onPressed: () => _showRules(context),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'v$appVersion',
                                style: const TextStyle(
                                  color: Colors.white24,
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 0.02),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Логотип с анимированными фишками ──────────────────────────────────────
  Widget _buildLogoArea() {
    final t = _time;
    return SizedBox(
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Светящийся ореол
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27AE60)
                      .withOpacity(0.12 + 0.06 * math.sin(t * 0.8)),
                  blurRadius: 50,
                  spreadRadius: 15,
                ),
              ],
            ),
          ),
          // Четыре фишки паттерн 2x2
          ..._buildBoardPieces(t),
        ],
      ),
    );
  }

  List<Widget> _buildBoardPieces(double t) {
    const gap = 27.0;
    const pieceR = 22.0;
    final pulse = 1.0 + 0.04 * math.sin(t * 1.5);

    final configs = [
      (dx: -gap, dy: -gap, isBlack: false),
      (dx: gap,  dy: -gap, isBlack: true),
      (dx: -gap, dy: gap,  isBlack: true),
      (dx: gap,  dy: gap,  isBlack: false),
    ];

    return configs.map((c) {
      return Transform.translate(
        offset: Offset(c.dx, c.dy),
        child: Transform.scale(
          scale: pulse,
          child: _buildDecoPiece(pieceR, c.isBlack, t, c.dx),
        ),
      );
    }).toList();
  }

  Widget _buildDecoPiece(double r, bool isBlack, double t, double dx) {
    return Container(
      width: r * 2,
      height: r * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(0.3, 0.3),
          radius: 0.85,
          colors: isBlack
              ? [const Color(0xFF2D2D2D), const Color(0xFF0A0A0A)]
              : [const Color(0xFFFFFFFF), const Color(0xFFCDD4DB)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
          BoxShadow(
            color: (isBlack
                ? const Color(0xFF27AE60)
                : Colors.white)
                .withOpacity(0.18 + 0.08 * math.sin(t + dx * 0.1)),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  // ── Заголовок с градиентом ────────────────────────────────────────────────
  Widget _buildTitle(AppLocalizations loc) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF56E39F), Color(0xFF27AE60), Color(0xFF5DADE2)],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Text(
            loc.appTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w900,
              letterSpacing: 8,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Text(
            loc.appSubtitle.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              letterSpacing: 4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  // ── Основная кнопка ───────────────────────────────────────────────────────
  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required Color glowColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 66,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: glowColor.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            splashColor: Colors.white24,
            highlightColor: Colors.white10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 18),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(0.6), size: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Текстовая кнопка ──────────────────────────────────────────────────────
  Widget _buildTextButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        backgroundColor: Colors.white.withOpacity(0.05),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Язык — общий обработчик, сразу сохраняет выбор ────────────────────────
  void _onLanguageChanged(AppLanguage lang) {
    setState(() => _language = lang);
    SettingsService().setLanguage(lang);
  }

  // ── Навигация (классический режим) ───────────────────────────────────────
  void _startGame(BuildContext context, GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          gameMode: mode,
          initialTheme: _selectedTheme,
          initialLanguage: _language,
          isModifierMode: false,
          onLanguageChanged: _onLanguageChanged,
        ),
      ),
    );
  }

  // ── Кнопка CHAOS MODE ────────────────────────────────────────────────────
  Widget _buildChaosButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFF1744).withOpacity(0.5),
            width: 1.5,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF1744).withOpacity(0.15),
              const Color(0xFFAA00FF).withOpacity(0.15),
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _openChaosMode(context),
            splashColor: const Color(0xFFFF1744).withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFAA00FF)],
                    ).createShader(b),
                    child: const Icon(Icons.local_fire_department_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF1744), Color(0xFFAA00FF)],
                    ).createShader(b),
                    child: const Text(
                      'CHAOS MODE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(0.4), size: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Навигация ─────────────────────────────────────────────────────────────
  void _openChaosMode(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ModeSelectScreen(
          initialTheme: _selectedTheme,
          initialLanguage: _language,
          onLanguageChanged: _onLanguageChanged,
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, setModalState) => SettingsScreen(
            currentTheme: _selectedTheme,
            soundEnabled: _audio.soundEnabled,
            onToggleSound: () {
              _audio.setSoundEnabled(!_audio.soundEnabled);
              setModalState(() {});
              setState(() {});
            },
            currentLanguage: _language,
            onLanguageChanged: (lang) {
              setModalState(() => _language = lang);
              _onLanguageChanged(lang);
            },
            onThemeChanged: (theme) {
              setState(() => _selectedTheme = theme);
              SettingsService().setBoardTheme(theme);
              Navigator.pop(context);
            },
            currentDifficulty: SettingsService().aiDifficulty,
            onDifficultyChanged: (d) {
              setModalState(() {});
              SettingsService().setAIDifficulty(d);
            },
            loc: _loc,
          ),
        ),
      ),
    );
  }

  void _showStats(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatsScreen(loc: _loc),
      ),
    );
  }

  void _showAchievements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AchievementsScreen(loc: _loc),
      ),
    );
  }

  void _showRules(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TutorialScreen(loc: _loc),
      ),
    );
  }
}