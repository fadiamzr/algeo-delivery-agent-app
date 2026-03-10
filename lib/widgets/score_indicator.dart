import 'package:flutter/material.dart';
import '../app_theme.dart';

class ScoreIndicator extends StatelessWidget {
  final double score;
  final double size;

  const ScoreIndicator({
    super.key,
    required this.score,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getScoreColor(score);
    final percentage = (score * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: score,
              strokeWidth: size * 0.08,
              backgroundColor: Theme.of(context).colorScheme.outline,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$percentage',
                style: TextStyle(
                  color: color,
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '%',
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: size * 0.14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ScoreBar extends StatelessWidget {
  final double score;

  const ScoreBar({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getScoreColor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            Text(
              '${(score * 100).round()}%',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score,
            minHeight: 6,
            backgroundColor: Theme.of(context).colorScheme.outline,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
