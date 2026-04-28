import 'dart:convert';
import 'api_service.dart';

class SyncService {
  static DateTime? _lastSyncTime;
  static bool _isSyncing = false;

  static DateTime? get lastSyncTime => _lastSyncTime;
  static bool get isSyncing => _isSyncing;

  static Future<SyncResult> syncDeliveries({
    Function(double progress, String message)? onProgress,
  }) async {
    _isSyncing = true;
    
    int totalItems = 0;
    int synced = 0;
    int failed = 0;

    try {
      onProgress?.call(0.1, 'Connecting to server...');
      
      final response = await ApiService.post('/sync/');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        onProgress?.call(0.6, 'Processing data...');
        final data = jsonDecode(response.body);
        
        // Count items received
        final deliveries = data['deliveries'] as List? ?? [];
        final history = data['history'] as List? ?? [];
        
        // The endpoint may return totalItems or we compute it
        totalItems = data['totalItems'] ?? (deliveries.length + history.length + 1); // +1 profile
        synced = totalItems; 
        failed = 0;
        
        final lastSyncStr = data['lastSync'];
        if (lastSyncStr != null) {
          _lastSyncTime = DateTime.parse(lastSyncStr).toLocal();
        } else {
          _lastSyncTime = DateTime.now();
        }
        
        onProgress?.call(1.0, 'Sync complete');
      } else {
        totalItems = 1;
        failed = 1;
        synced = 0;
        onProgress?.call(1.0, 'Sync failed: Server Error');
      }
    } catch (e) {
      totalItems = 1;
      failed = 1;
      synced = 0;
      onProgress?.call(1.0, 'Sync failed: Network Error');
    }

    _isSyncing = false;
    _lastSyncTime ??= DateTime.now();

    return SyncResult(
      totalItems: totalItems,
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
  double get successRate => totalItems == 0 ? 1.0 : syncedItems / totalItems;
}
