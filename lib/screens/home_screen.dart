import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';
import '../utils/board_theme.dart';
import '../utils/audio_service.dart';
import '../utils/app_localizations.dart';
import '../version.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'tutorial_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Данные парящей фишки
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingPiece {
  double x, y, size, speed, angle, rotationSpeed, opacity;
  bool isBlack;

  _FloatingPiece({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.rotationSpeed,
    required this.opacity,
    required this.isBlack,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter для анимированного фона
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundPainter extends CustomPainter {
  final List<_FloatingPiece> pieces;
  final double time;

  _BackgroundPainter({required this.pieces, required this.time});

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

    for (final p in pieces) {
      final px = p.x * size.width;
      final py = (p.y + math.sin(time * p.speed + p.angle) * 0.03) * size.height;
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

  void _drawGlowOrb(Canvas canvas, Offset center, double r, Color color, double opacity) {
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = color.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter o) => o.time != time;
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
  BoardTheme _selectedTheme = BoardTheme.classic;
  final AudioService _audio = AudioService();
  AppLanguage _language = AppLanguage.english;

  late AnimationController _bgController;
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

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

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
    return List.generate(14, (i) => _FloatingPiece(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: 8 + rng.nextDouble() * 18,
      speed: 0.3 + rng.nextDouble() * 0.5,
      angle: rng.nextDouble() * math.pi * 2,
      rotationSpeed: (rng.nextDouble() - 0.5) * 0.4,
      opacity: 0.06 + rng.nextDouble() * 0.1,
      isBlack: i.isEven,
    ));
  }

  @override
  void dispose() {
    _bgController.dispose();
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
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) => SizedBox.expand(
              child: CustomPaint(
                painter: _BackgroundPainter(
                  pieces: _pieces,
                  time: _bgController.value * math.pi * 2,
                ),
              ),
            ),
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
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white54, size: 26),
                      onPressed: () => _showSettings(context),
                      tooltip: loc.settings,
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
    return AnimatedBuilder(
      animation: _bgController,
      builder: (_, __) {
        final t = _bgController.value * math.pi * 2;
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
                          .withOpacity(0.12 + 0.06 * math.sin(t)),
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
      },
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

  // ── Навигация ─────────────────────────────────────────────────────────────
  void _startGame(BuildContext context, GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          gameMode: mode,
          initialTheme: _selectedTheme,
          initialLanguage: _language,
          onLanguageChanged: (lang) => setState(() => _language = lang),
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
              setState(() => _language = lang);
            },
            onThemeChanged: (theme) {
              setState(() => _selectedTheme = theme);
              Navigator.pop(context);
            },
            loc: _loc,
          ),
        ),
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