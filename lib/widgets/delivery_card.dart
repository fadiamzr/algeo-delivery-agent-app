import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/delivery.dart';
import 'status_badge.dart';
import 'package:intl/intl.dart';

class DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final VoidCallback? onTap;

  const DeliveryCard({
    super.key,
    required this.delivery,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasVerification = delivery.addressVerification != null;
    final score = delivery.addressVerification?.confidenceScore;
    final riskCount = delivery.addressVerification?.riskFlags.length ?? 0;
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    delivery.id,
                    style: const TextStyle(
                      color: AppTheme.accentPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  StatusBadge(status: delivery.statusLabel),
                ],
              ),
              const SizedBox(height: 12),

              // Customer name
              Row(
                children: [
                  Icon(Icons.person_outline,
                      color: cs.onSurfaceVariant, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      delivery.customerName,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.location_on_outlined,
                        color: cs.onSurfaceVariant, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      delivery.rawAddress,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bottom row: Score + Date + Risk flags
              Row(
                children: [
                  // Score indicator
                  if (hasVerification && score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.getScoreColor(score)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_outlined,
                              color: AppTheme.getScoreColor(score), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${(score * 100).round()}%',
                            style: TextStyle(
                              color: AppTheme.getScoreColor(score),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.help_outline,
                              color: cs.onSurfaceVariant, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Not verified',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(width: 8),

                  // Risk flags count
                  if (riskCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flag_outlined,
                              color: AppTheme.errorRed, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '$riskCount',
                            style: const TextStyle(
                              color: AppTheme.errorRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Scheduled date
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule,
                          color: cs.onSurfaceVariant, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, HH:mm')
                            .format(delivery.scheduledDate),
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
