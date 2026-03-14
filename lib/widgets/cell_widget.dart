import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../utils/constants.dart';

/// Виджет клетки игрового поля
class CellWidget extends StatefulWidget {
  final Cell cell;
  final bool isValidMove;  // Для кликабельности
  final bool showHint;     // Для отображения подсказки
  final VoidCallback? onTap;
  final Color boardColor;
  final Color gridLineColor;

  const CellWidget({
    Key? key,
    required this.cell,
    this.isValidMove = false,
    this.showHint = false,
    this.onTap,
    this.boardColor = GameConstants.boardColor,
    this.gridLineColor = GameConstants.gridLineColor,
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: GameConstants.flipDuration,
      vsync: this,
    );

    // Анимация переворота (вращение по оси Y)
    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Анимация масштаба (появление)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _previousPlayer = widget.cell.player;

    // Если фишка уже есть при инициализации - сразу показываем
    if (!widget.cell.isEmpty) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Проверяем изменение игрока
    if (_previousPlayer != widget.cell.player && !widget.cell.isEmpty) {
      if (_previousPlayer == Player.none) {
        // Новая фишка - анимация появления
        _isFlipping = false;
        _controller.forward(from: 0.0);
      } else {
        // Переворот фишки - 3D анимация
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
    return GestureDetector(
      onTap: widget.isValidMove ? widget.onTap : null,  // Кликабельность на основе isValidMove
      child: Container(
        margin: const EdgeInsets.all(GameConstants.cellPadding),
        decoration: BoxDecoration(
          color: widget.boardColor,
          borderRadius: BorderRadius.circular(GameConstants.borderRadius),
          border: Border.all(
            color: widget.gridLineColor,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Индикатор валидного хода с пульсацией - показываем только если showHint == true
            if (widget.showHint)
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: GameConstants.validMoveColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: GameConstants.validMoveColor,
                                blurRadius: 8 * value,
                                spreadRadius: 2 * value,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    // Перезапуск анимации (пульсация)
                    if (mounted && widget.showHint) {
                      setState(() {});
                    }
                  },
                ),
              ),

            // Фишка с анимацией
            if (!widget.cell.isEmpty)
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    if (_isFlipping) {
                      // 3D переворот
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // перспектива
                          ..rotateY(_flipAnimation.value),
                        child: _buildPiece(
                          // Меняем цвет на половине анимации
                          _flipAnimation.value > math.pi / 2
                              ? widget.cell.player
                              : _previousPlayer ?? widget.cell.player,
                        ),
                      );
                    } else {
                      // Анимация появления (масштаб + небольшое вращение)
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: (1 - _scaleAnimation.value) * 0.5,
                          child: _buildPiece(widget.cell.player),
                        ),
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Создать фишку
  Widget _buildPiece(Player player) {
    final isBlack = player == Player.black;
    final baseColors = isBlack
        ? GameConstants.blackGradient
        : GameConstants.whiteGradient;

    return FractionallySizedBox(
      widthFactor: GameConstants.pieceScale,
      heightFactor: GameConstants.pieceScale,
      child: Stack(
        children: [
          // Основной корпус фишки — радиальный градиент снизу-справа (объём)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: baseColors,
                center: const Alignment(0.3, 0.4),
                radius: 0.85,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isBlack ? 0.5 : 0.25),
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
                // Внутренняя тень снизу для глубины
                BoxShadow(
                  color: Colors.black.withOpacity(isBlack ? 0.3 : 0.12),
                  blurRadius: 3,
                  offset: const Offset(1, 2),
                  spreadRadius: -1,
                ),
              ],
            ),
          ),
          // Блик — белое пятно сверху-слева (имитация освещения)
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
                    center: Alignment.center,
                    radius: 1.0,
                  ),
                ),
              ),
            ),
          ),
          // Тонкий ободок для белых фишек (выделение края)
          if (!isBlack)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 0.8,
                ),
              ),
            ),
        ],
      ),
    );
  }
}