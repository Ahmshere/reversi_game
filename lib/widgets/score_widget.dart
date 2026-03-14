import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Виджет отображения счета
class ScoreWidget extends StatelessWidget {
  final int blackScore;
  final int whiteScore;
  final Player currentPlayer;
  final String blackLabel;
  final String whiteLabel;

  const ScoreWidget({
    Key? key,
    required this.blackScore,
    required this.whiteScore,
    required this.currentPlayer,
    this.blackLabel = 'Black',
    this.whiteLabel = 'White',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPlayerScore(
            color: GameConstants.blackPlayerColor,
            score: blackScore,
            isActive: currentPlayer == Player.black,
            label: blackLabel,
          ),
          Container(
            width: 2,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildPlayerScore(
            color: GameConstants.whitePlayerColor,
            score: whiteScore,
            isActive: currentPlayer == Player.white,
            label: whiteLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerScore({
    required Color color,
    required int score,
    required bool isActive,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? Colors.yellowAccent : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isActive
                    ? [
                  BoxShadow(
                    color: Colors.yellowAccent.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GameConstants.scoreStyle.copyWith(
                fontSize: 16,
                color: isActive ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: GameConstants.scoreStyle.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.white70,
          ),
        ),
      ],
    );
  }
}