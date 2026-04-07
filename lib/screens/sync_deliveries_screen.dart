import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../services/sync_service.dart';

class SyncDeliveriesScreen extends StatefulWidget {
  const SyncDeliveriesScreen({super.key});

  @override
  State<SyncDeliveriesScreen> createState() => _SyncDeliveriesScreenState();
}

class _SyncDeliveriesScreenState extends State<SyncDeliveriesScreen> {
  bool _isSyncing = false;
  double _progress = 0.0;
  String _statusMessage = '';
  SyncResult? _lastResult;

  Future<void> _startSync() async {
    setState(() {
      _isSyncing = true;
      _progress = 0.0;
      _statusMessage = 'Starting sync...';
      _lastResult = null;
    });

    final result = await SyncService.syncDeliveries(
      onProgress: (progress, message) {
        setState(() {
          _progress = progress;
          _statusMessage = message;
        });
      },
    );

    setState(() {
      _isSyncing = false;
      _lastResult = result;
      _statusMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Sync Deliveries',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              if (SyncService.lastSyncTime != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.successGreen, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Synced',
                        style: TextStyle(
                          color: AppTheme.successGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Sync icon hero
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.infoBlue.withValues(alpha: 0.12),
                        cs.surfaceContainerHighest,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.infoBlue.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      AnimatedRotation(
                        turns: _isSyncing ? 1 : 0,
                        duration: const Duration(seconds: 2),
                        child: Icon(
                          Icons.sync_rounded,
                          size: 64,
                          color: _isSyncing ? AppTheme.accentPrimary : AppTheme.infoBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isSyncing ? 'Syncing...' : 'Offline Data Sync',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isSyncing
                            ? _statusMessage
                            : 'Synchronize deliveries, verifications, and feedback with the server',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                      ),
                      if (_isSyncing) ...[
                        const SizedBox(height: 24),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 8,
                            backgroundColor: cs.outline,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentPrimary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_progress * 100).round()}%',
                          style: const TextStyle(
                            color: AppTheme.accentPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Last sync info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule, color: AppTheme.accentPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Last Sync',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        SyncService.lastSyncTime != null
                            ? DateFormat('MMM d, yyyy • HH:mm:ss').format(SyncService.lastSyncTime!)
                            : 'Never synced',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (_lastResult != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _lastResult!.hasErrors
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle_outline,
                              color: _lastResult!.hasErrors
                                  ? AppTheme.warningYellow
                                  : AppTheme.successGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sync Result',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _lastResult!.hasErrors
                                    ? AppTheme.warningYellow
                                    : AppTheme.successGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _SyncStat(label: 'Total Items', value: '${_lastResult!.totalItems}'),
                        const SizedBox(height: 8),
                        _SyncStat(
                          label: 'Synced',
                          value: '${_lastResult!.syncedItems}',
                          valueColor: AppTheme.successGreen,
                        ),
                        if (_lastResult!.failedItems > 0) ...[
                          const SizedBox(height: 8),
                          _SyncStat(
                            label: 'Failed',
                            value: '${_lastResult!.failedItems}',
                            valueColor: AppTheme.errorRed,
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 12),

                // Sync items
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined, color: AppTheme.accentPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Sync Items',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const _SyncItem(icon: Icons.feedback_outlined, label: 'Pending Feedback', count: 3),
                      Divider(height: 1, color: cs.outline),
                      const _SyncItem(icon: Icons.verified_outlined, label: 'Verification Results', count: 5),
                      Divider(height: 1, color: cs.outline),
                      const _SyncItem(icon: Icons.local_shipping_outlined, label: 'New Deliveries', count: 2),
                      Divider(height: 1, color: cs.outline),
                      const _SyncItem(icon: Icons.update, label: 'Address Updates', count: 1),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : _startSync,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primaryDark),
                          )
                        : const Icon(Icons.sync_rounded, size: 26),
                    label: Text(
                      _isSyncing ? 'Syncing...' : 'Sync Now',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SyncStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _SyncStat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? cs.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SyncItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  const _SyncItem({required this.icon, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: cs.onSurfaceVariant, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(color: cs.onSurface, fontSize: 14)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppTheme.accentPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
