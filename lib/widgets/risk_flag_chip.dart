import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/address_verification.dart';

class RiskFlagChip extends StatelessWidget {
  final RiskFlag flag;

  const RiskFlagChip({
    super.key,
    required this.flag,
  });

  Color _getSeverityColor() {
    switch (flag.severity) {
      case RiskSeverity.high:
        return AppTheme.errorRed;
      case RiskSeverity.medium:
        return AppTheme.warningYellow;
      case RiskSeverity.low:
        return AppTheme.accentPrimary;
    }
  }

  IconData _getSeverityIcon() {
    switch (flag.severity) {
      case RiskSeverity.high:
        return Icons.error_outline;
      case RiskSeverity.medium:
        return Icons.warning_amber_rounded;
      case RiskSeverity.low:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor();
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_getSeverityIcon(), color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      flag.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        flag.severity.name.toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  flag.description,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
