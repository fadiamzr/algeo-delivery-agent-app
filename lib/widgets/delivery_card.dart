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
    final riskCount = delivery.riskFlagsCount;
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
              // Header: ID/Code + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    delivery.deliveryCode ?? 'DEL-${delivery.id.padLeft(3, '0')}',
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
                      delivery.customerName.isNotEmpty
                          ? delivery.customerName
                          : 'Unknown Customer',
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

              // Bottom row: Score + Risk flags + Date/Verify
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Score indicator
                  if (hasVerification && score != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.getScoreColor(score)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
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
                    ),
                    if (riskCount > 0) const SizedBox(width: 8),
                  ],

                  // Risk flags count
                  if (riskCount > 0)
                    Builder(
                      builder: (context) {
                        final riskColor = riskCount >= 2 
                            ? AppTheme.errorRed 
                            : AppTheme.warningYellow;
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: riskColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flag_outlined,
                                  color: riskColor, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '$riskCount',
                                style: TextStyle(
                                  color: riskColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    ),

                  const Spacer(),

                  // Verify action button or Scheduled date
                  if (!hasVerification && delivery.status != DeliveryStatus.completed)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: AppTheme.accentPrimary.withValues(alpha: 0.1),
                        foregroundColor: AppTheme.accentPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.my_location, size: 14),
                      label: const Text(
                        'Verify',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/verify-address',
                          arguments: delivery,
                        );
                      },
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.7), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, HH:mm')
                              .format(delivery.scheduledDate),
                          style: TextStyle(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
