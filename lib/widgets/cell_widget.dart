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
  final bool isModifierMode; // ← Chaos режим — полупрозрачный фон
  final bool isSuggested;   // ← клетка с подсказкой "лучший ход"
  final bool isExplosionNeighbor; // ← фишка перевёрнута взрывом соседней клетки
  final bool isBonusTriggered;    // ← на этой клетке только что сработал бонус

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
    this.isModifierMode = false,
    this.isSuggested = false,
    this.isExplosionNeighbor = false,
    this.isBonusTriggered = false,
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
  late Animation<double> _dustAnim;       // всплеск пыли/обломков
  List<_DustParticle> _dustParticles = [];

  // ── Анимация взрыва ──────────────────────────────────────────────────────
  late AnimationController _explosionCtrl;
  late Animation<double> _explosionScale;
  late Animation<double> _explosionFade;
  bool _showExplosion = false;

  // ── Анимация подсветки ИИ ────────────────────────────────────────────────
  late AnimationController _aiGlowCtrl;
  late Animation<double> _aiGlowAnim;

  // ── Анимация салюта бонуса ────────────────────────────────────────────────
  late AnimationController _bonusCtrl;
  late Animation<double> _bonusScale;
  late Animation<double> _bonusFade;
  bool _showBonusBurst = false;
  List<double> _bonusSparkleAngles = [];

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

    // Провал — увеличенная длительность даёт время на "тряску" перед
    // разломом, сам разлом, всплеск пыли и падение фишки в яму.
    _trapdoorCtrl = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _crackAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _trapdoorCtrl,
        curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
      ),
    );
    _dustAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _trapdoorCtrl,
        curve: const Interval(0.22, 0.55, curve: Curves.easeOut),
      ),
    );
    _trapdoorY = Tween<double>(begin: 0, end: 54).animate(
      CurvedAnimation(
        parent: _trapdoorCtrl,
        curve: const Interval(0.32, 0.78, curve: Curves.easeIn),
      ),
    );
    _trapdoorFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _trapdoorCtrl,
        curve: const Interval(0.5, 0.82, curve: Curves.easeIn),
      ),
    );
    _trapdoorScale = Tween<double>(begin: 1, end: 0.3).animate(
      CurvedAnimation(
        parent: _trapdoorCtrl,
        curve: const Interval(0.32, 0.78, curve: Curves.easeIn),
      ),
    );
    _pitAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _trapdoorCtrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );
    _dustParticles = _generateDustParticles();

    // Взрыв
    _explosionCtrl = AnimationController(
      duration: const Duration(milliseconds: 850),
      vsync: this,
    );
    _explosionScale = Tween<double>(begin: 0.4, end: 2.6).animate(
      CurvedAnimation(parent: _explosionCtrl, curve: Curves.easeOut),
    );
    _explosionFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _explosionCtrl,
        curve: const Interval(0.35, 1.0, curve: Curves.easeIn),
      ),
    );

    // Подсветка ИИ
    _aiGlowCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _aiGlowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _aiGlowCtrl, curve: Curves.easeInOut),
    );

    // Салют бонуса
    _bonusCtrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _bonusScale = Tween<double>(begin: 0.3, end: 1.8).animate(
      CurvedAnimation(parent: _bonusCtrl, curve: Curves.easeOut),
    );
    _bonusFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _bonusCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
    _bonusSparkleAngles = List.generate(
      8, (i) => (i / 8) * math.pi * 2 + math.Random().nextDouble() * 0.3,
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

    // ── Эта клетка попала под взрыв соседней взрывной клетки ───────────────
    if (!oldWidget.isExplosionNeighbor && widget.isExplosionNeighbor) {
      _triggerExplosionFlash();
    }

    // ── На этой клетке только что сработал бонус ────────────────────────────
    if (!oldWidget.isBonusTriggered && widget.isBonusTriggered) {
      _triggerBonusBurst();
    }
  }

  List<_DustParticle> _generateDustParticles() {
    final rng = math.Random();
    return List.generate(10, (_) {
      return _DustParticle(
        angle: rng.nextDouble() * math.pi * 2,
        distance: 10 + rng.nextDouble() * 16,
        size: 2 + rng.nextDouble() * 3.5,
        riseHeight: 6 + rng.nextDouble() * 10,
        isDark: rng.nextBool(),
      );
    });
  }

  void _triggerExplosionFlash() {
    setState(() => _showExplosion = true);
    _explosionCtrl.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _showExplosion = false);
    });
  }

  void _triggerBonusBurst() {
    setState(() => _showBonusBurst = true);
    _bonusCtrl.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _showBonusBurst = false);
    });
  }

  @override
  void dispose() {
    _pieceCtrl.dispose();
    _trapdoorCtrl.dispose();
    _explosionCtrl.dispose();
    _aiGlowCtrl.dispose();
    _bonusCtrl.dispose();
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
          _pieceCtrl, _trapdoorCtrl, _explosionCtrl, _aiGlowCtrl, _bonusCtrl,
        ]),
        builder: (context, _) {
          return Container(
            margin: const EdgeInsets.all(GameConstants.cellPadding),
            decoration: BoxDecoration(
              color: widget.isModifierMode && modifier == CellType.normal
                  ? widget.boardColor.withOpacity(0.72)
                  : _cellBg(modifier, isTrapdoor),
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

                  // Трещины перед провалом
                  if (isTrapdoor && _crackAnim.value > 0 && _pitAnim.value < 1)
                    _buildCracks(),

                  // Яма после провала
                  if (isTrapdoor && _pitAnim.value > 0)
                    _buildPit(),

                  // Иконка модификатора
                  if (widget.cell.isEmpty && modifier != CellType.normal && !isTrapdoor)
                    Center(child: _buildModifierIcon(modifier)),

                  // Подсказка (точка допустимого хода)
                  if (widget.showHint && !isTrapdoor)
                    Center(child: _buildHint()),

                  // Фишка
                  if (!widget.cell.isEmpty)
                    Center(child: _buildPieceAnimated(isTrapdoor)),

                  // Всплеск пыли и обломков в момент провала
                  if (isTrapdoor && _dustAnim.value > 0 && _dustAnim.value < 1)
                    _buildDustBurst(),

                  // Подсказка "лучший ход" (кнопка Hint)
                  if (widget.isSuggested && !isTrapdoor)
                    Center(child: _buildSuggestion()),

                  // Вспышка взрыва
                  if (_showExplosion)
                    _buildExplosionFlash(),

                  // Салют бонуса
                  if (_showBonusBurst)
                    _buildBonusBurst(),

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

  // ── Трещины (раскрываются перед провалом) ────────────────────────────────
  Widget _buildCracks() {
    // Пока пол ещё не стал полноценной ямой — трещины видны отчётливо,
    // затем гаснут по мере того как яма занимает их место.
    final opacity = (_crackAnim.value * (1 - _pitAnim.value * 0.7)).clamp(0.0, 1.0);
    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: _CrackPainter(progress: _crackAnim.value),
        ),
      ),
    );
  }

  // ── Всплеск пыли и обломков в момент провала ─────────────────────────────
  Widget _buildDustBurst() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _DustPainter(
            progress: _dustAnim.value,
            particles: _dustParticles,
          ),
        ),
      ),
    );
  }

  // ── Яма (тёмная дыра с радиальным градиентом) ────────────────────────────
  Widget _buildPit() {
    // Слабое пульсирующее тлеющее свечение по краю ямы — держит взгляд
    // на клетке ещё немного после того, как фишка исчезла.
    final emberPulse = 0.5 + 0.5 * math.sin(_trapdoorCtrl.value * math.pi * 6);
    return Positioned.fill(
      child: Opacity(
        opacity: _pitAnim.value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GameConstants.borderRadius),
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.85,
              colors: [
                Colors.black,
                const Color(0xFF150800).withOpacity(0.92),
                Colors.transparent,
              ],
              stops: const [0.0, 0.65, 1.0],
            ),
            border: Border.all(
              color: const Color(0xFFFF6B00)
                  .withOpacity(0.25 * emberPulse * _pitAnim.value),
              width: 1.2,
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
      // фишка проваливается вниз.
      // Пока трещина только раскрывается (до начала падения) — фишку
      // слегка трясёт, чтобы усилить ощущение разрушения пола.
      final fallProgress = (_trapdoorY.value / 54).clamp(0.0, 1.0);
      final rumble = _crackAnim.value * (1 - fallProgress);
      final jitterX = math.sin(_trapdoorCtrl.value * 70) * 2.2 * rumble;
      final jitterY = math.cos(_trapdoorCtrl.value * 55) * 1.6 * rumble;

      return Transform.translate(
        offset: Offset(jitterX, jitterY),
        child: Transform.translate(
          offset: Offset(0, _trapdoorY.value),
          child: Transform.scale(
            scale: _trapdoorScale.value,
            child: Opacity(
              opacity: _trapdoorFade.value.clamp(0.0, 1.0),
              child: _buildPiece(widget.cell.player),
            ),
          ),
        ),
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
    // Общий прогресс (0..1) — используем и для яркой вспышки фона клетки,
    // и для расширяющегося огненного кольца, и для самой иконки взрыва.
    final t = _explosionCtrl.value;
    final flashOpacity = (1 - t * 3).clamp(0.0, 1.0); // резкая вспышка в начале

    return Positioned.fill(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Резкая яркая вспышка всей клетки в первый момент удара
          if (flashOpacity > 0)
            Container(color: Colors.white.withOpacity(flashOpacity * 0.85)),

          // Расширяющееся огненное кольцо
          Opacity(
            opacity: _explosionFade.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _explosionScale.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFCC66).withOpacity(0.8),
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ),

          // Основная вспышка + иконка
          Opacity(
            opacity: _explosionFade.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _explosionScale.value * 0.75,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF6030).withOpacity(0.75),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6030).withOpacity(0.55),
                      blurRadius: 22,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('💥', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Салют бонуса (доп. ход) ──────────────────────────────────────────────
  Widget _buildBonusBurst() {
    final fade = _bonusFade.value.clamp(0.0, 1.0);
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Золотое кольцо расширяется наружу
            Opacity(
              opacity: fade,
              child: Transform.scale(
                scale: _bonusScale.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFCC00).withOpacity(0.8),
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ),
            // Искры-звёздочки разлетаются по кругу
            ..._bonusSparkleAngles.map((angle) {
              final travel = _bonusScale.value * 16;
              final dx = math.cos(angle) * travel;
              final dy = math.sin(angle) * travel;
              return Opacity(
                opacity: fade,
                child: Transform.translate(
                  offset: Offset(dx, dy),
                  child: const Text('✨', style: TextStyle(fontSize: 11)),
                ),
              );
            }),
            // Звезда в центре
            Opacity(
              opacity: fade,
              child: Transform.scale(
                scale: 0.6 + 0.4 * (1 - fade),
                child: const Text('⭐', style: TextStyle(fontSize: 22)),
              ),
            ),
          ],
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
      duration: const Duration(milliseconds: 700),
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

  // ── Подсказка "лучший ход" ────────────────────────────────────────────────
  Widget _buildSuggestion() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.75, end: 1.15),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOut,
      builder: (_, v, __) => Transform.scale(
        scale: v,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFD700).withOpacity(0.22),
            border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.6),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.lightbulb_rounded,
              color: Color(0xFFFFD700), size: 14),
        ),
      ),
      onEnd: () { if (mounted && widget.isSuggested) setState(() {}); },
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
    if (widget.isModifierMode && type != CellType.normal) {
      // В Chaos режиме — полупрозрачный фон чтобы видеть огненный задник
      switch (type) {
        case CellType.blocked:   return Colors.black.withOpacity(0.55);
        case CellType.explosive: return const Color(0xFFFF3000).withOpacity(0.30);
        case CellType.bonus:     return const Color(0xFFFFAA00).withOpacity(0.25);
        case CellType.normal:    return widget.boardColor;
      }
    }
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

// ── Частица пыли/обломков при провале пола ──────────────────────────────────
class _DustParticle {
  final double angle;      // направление разлёта
  final double distance;   // на сколько px разлетается
  final double size;
  final double riseHeight; // дополнительный подъём вверх перед оседанием
  final bool isDark;

  const _DustParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.riseHeight,
    required this.isDark,
  });
}

class _DustPainter extends CustomPainter {
  final double progress; // 0..1
  final List<_DustParticle> particles;

  const _DustPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final eased = Curves.easeOut.transform(progress);
    final fade = (1 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      // Обломки взлетают вверх, затем чуть проседают — движение по дуге
      final travel = eased * p.distance;
      final dx = center.dx + math.cos(p.angle) * travel;
      final riseArc = math.sin(eased * math.pi) * p.riseHeight;
      final dy = center.dy + math.sin(p.angle) * travel * 0.4 - riseArc;

      final paint = Paint()
        ..color = (p.isDark ? const Color(0xFF3D2A1A) : const Color(0xFF8A6A4A))
            .withOpacity(fade * 0.85);
      canvas.drawCircle(Offset(dx, dy), p.size * (1 - progress * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(_DustPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ── Трещины на клетке перед провалом ────────────────────────────────────────
class _CrackPainter extends CustomPainter {
  final double progress; // 0..1

  const _CrackPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.8 * progress)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    // 4 трещины-луча под разными углами, с небольшим изломом посередине
    const angles = [0.4, 1.9, 3.3, 5.0];
    for (final a in angles) {
      final reach = (size.width * 0.42) * progress;
      final mid = Offset(
        center.dx + math.cos(a) * reach * 0.5 + math.cos(a + 1.4) * 3,
        center.dy + math.sin(a) * reach * 0.5 + math.sin(a + 1.4) * 3,
      );
      final end = Offset(
        center.dx + math.cos(a) * reach,
        center.dy + math.sin(a) * reach,
      );
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(mid.dx, mid.dy)
        ..lineTo(end.dx, end.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_CrackPainter oldDelegate) =>
      oldDelegate.progress != progress;
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