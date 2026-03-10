class SyncService {
  static DateTime? _lastSyncTime;
  static bool _isSyncing = false;

  static DateTime? get lastSyncTime => _lastSyncTime;
  static bool get isSyncing => _isSyncing;

  static Future<SyncResult> syncDeliveries({
    Function(double progress, String message)? onProgress,
  }) async {
    _isSyncing = true;

    final steps = [
      'Connecting to server...',
      'Uploading pending feedback...',
      'Uploading verification results...',
      'Downloading new deliveries...',
      'Downloading updated addresses...',
      'Syncing verification history...',
      'Finalizing sync...',
    ];

    int synced = 0;
    int failed = 0;

    for (int i = 0; i < steps.length; i++) {
      final progress = (i + 1) / steps.length;
      onProgress?.call(progress, steps[i]);
      await Future.delayed(const Duration(milliseconds: 600));

      // Simulate occasional failure
      if (i == 4) {
        failed = 1;
      } else {
        synced++;
      }
    }

    _lastSyncTime = DateTime.now();
    _isSyncing = false;

    return SyncResult(
      totalItems: steps.length,
      syncedItems: synced,
      failedItems: failed,
      syncTime: _lastSyncTime!,
    );
  }
}

class SyncResult {
  final int totalItems;
  final int syncedItems;
  final int failedItems;
  final DateTime syncTime;

  SyncResult({
    required this.totalItems,
    required this.syncedItems,
    required this.failedItems,
    required this.syncTime,
  });

  bool get hasErrors => failedItems > 0;
  double get successRate => syncedItems / totalItems;
}
