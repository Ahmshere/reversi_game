import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../utils/board_theme.dart';
import '../utils/app_localizations.dart';
import 'game_screen.dart';

/// Экран выбора режима для Chaos Mode (VS Player или VS AI)
class ModeSelectScreen extends StatefulWidget {
  final BoardTheme initialTheme;
  final AppLanguage initialLanguage;
  final Function(AppLanguage)? onLanguageChanged;

  const ModeSelectScreen({
    Key? key,
    this.initialTheme = BoardTheme.classic,
    this.initialLanguage = AppLanguage.english,
    this.onLanguageChanged,
  }) : super(key: key);

  @override
  State<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slide1;
  late Animation<double> _slide2;

  AppLocalizations get _loc => AppLocalizations(widget.initialLanguage);

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _fadeAnim = CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _slide1 = CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic));
    _slide2 = CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF110A1F),
      body: Stack(
        children: [
          // Анимированный фон — хаотичные частицы
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) => SizedBox.expand(
              child: CustomPaint(
                painter: _ChaosBgPainter(_bgController.value),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Кнопка назад
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Иконка ──────────────────────────────────────────
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: _buildChaosIcon(),
                        ),

                        const SizedBox(height: 24),

                        // ── Заголовок ────────────────────────────────────────
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (b) => const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B35),
                                    Color(0xFFFF1744),
                                    Color(0xFFAA00FF),
                                  ],
                                ).createShader(b),
                                child: Text(
                                  _loc.chaosModeTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 54,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 10,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                              Text(
                                _loc.chaosModeSubtitle,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Описание ─────────────────────────────────────────
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white.withOpacity(0.04),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Text(
                              _loc.chaosModeDesc,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.06),

                        // ── VS PLAYER ────────────────────────────────────────
                        FadeTransition(
                          opacity: _slide1,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-0.15, 0),
                              end: Offset.zero,
                            ).animate(_slide1),
                            child: _buildChaosButton(
                              label: _loc.vsPlayer,
                              icon: Icons.people_alt_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B35), Color(0xFFCC3300)],
                              ),
                              glowColor: const Color(0xFFFF6B35),
                              onPressed: () => _startGame(GameMode.vsPlayer),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── VS AI ────────────────────────────────────────────
                        FadeTransition(
                          opacity: _slide2,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.15, 0),
                              end: Offset.zero,
                            ).animate(_slide2),
                            child: _buildChaosButton(
                              label: _loc.vsComputer,
                              icon: Icons.smart_toy_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFAA00FF), Color(0xFF6600CC)],
                              ),
                              glowColor: const Color(0xFFAA00FF),
                              onPressed: () => _startGame(GameMode.vsAI),
                            ),
                          ),
                        ),
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

  // ── Анимированная иконка хаоса ──────────────────────────────────────────

  Widget _buildChaosIcon() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (_, __) {
        final t = _bgController.value * math.pi * 2;
        return SizedBox(
          height: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Пульсирующий ореол
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1744)
                          .withOpacity(0.15 + 0.08 * math.sin(t)),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              // 4 фишки в «разлетающемся» паттерне
              ..._buildScatteredPieces(t),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildScatteredPieces(double t) {
    final configs = [
      (dx: -22.0, dy: -22.0, isBlack: false, phase: 0.0),
      (dx: 22.0, dy: -20.0, isBlack: true, phase: 1.1),
      (dx: -20.0, dy: 22.0, isBlack: true, phase: 2.3),
      (dx: 22.0, dy: 22.0, isBlack: false, phase: 3.4),
    ];
    return configs.map((c) {
      final wobble = math.sin(t * 1.3 + c.phase) * 3;
      return Transform.translate(
        offset: Offset(c.dx + wobble, c.dy + math.cos(t + c.phase) * 2),
        child: Transform.rotate(
          angle: t * 0.4 * (c.isBlack ? 1 : -1),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(0.3, 0.3),
                radius: 0.85,
                colors: c.isBlack
                    ? [const Color(0xFF2D2D2D), const Color(0xFF080808)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFCDD4DB)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (c.isBlack
                      ? const Color(0xFFFF1744)
                      : const Color(0xFFAA00FF))
                      .withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // ── Кнопка в стиле хаоса ────────────────────────────────────────────────

  Widget _buildChaosButton({
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
              color: glowColor.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                      letterSpacing: 1.5,
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

  void _startGame(GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          gameMode: mode,
          initialTheme: widget.initialTheme,
          initialLanguage: widget.initialLanguage,
          isModifierMode: true,
          onLanguageChanged: widget.onLanguageChanged,
        ),
      ),
    );
  }
}

// ── Фоновый Painter для хаотичных частиц ──────────────────────────────────

class _ChaosBgPainter extends CustomPainter {
  final double t;
  _ChaosBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Градиент фона
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF110A1F), Color(0xFF1A0510), Color(0xFF0D0820)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Орбы
    _glow(canvas, Offset(size.width * 0.2, size.height * 0.3),
        90, const Color(0xFFFF1744), 0.08);
    _glow(canvas, Offset(size.width * 0.8, size.height * 0.6),
        80, const Color(0xFFAA00FF), 0.07);
    _glow(canvas, Offset(size.width * 0.5, size.height * 0.15),
        60, const Color(0xFFFF6B35), 0.06);

    // Частицы
    final rng = math.Random(7);
    for (int i = 0; i < 18; i++) {
      final px = rng.nextDouble() * size.width;
      final py = rng.nextDouble() * size.height;
      final r = 3.0 + rng.nextDouble() * 8.0;
      final phase = rng.nextDouble() * math.pi * 2;
      final speed = 0.3 + rng.nextDouble() * 0.5;
      final dy = math.sin(t * math.pi * 2 * speed + phase) * 15;
      final opacity = 0.04 + rng.nextDouble() * 0.08;

      canvas.drawCircle(
        Offset(px, py + dy),
        r,
        Paint()
          ..color = (i.isEven
              ? const Color(0xFFFF1744)
              : const Color(0xFFAA00FF))
              .withOpacity(opacity),
      );
    }
  }

  void _glow(Canvas canvas, Offset c, double r, Color color, double opacity) {
    canvas.drawCircle(
      c, r,
      Paint()
        ..color = color.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50),
    );
  }

  @override
  bool shouldRepaint(_ChaosBgPainter o) => o.t != t;
}