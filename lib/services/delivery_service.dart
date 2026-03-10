import '../models/delivery.dart';
import '../mock_data/mock_deliveries.dart';

class DeliveryService {
  static List<Delivery> _deliveries = [];

  static Future<List<Delivery>> getAssignedDeliveries() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _deliveries = MockDeliveries.getDeliveries();
    return _deliveries;
  }

  static Future<Delivery?> getDeliveryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _deliveries.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<List<Delivery>> filterByStatus(DeliveryStatus? status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (status == null) return _deliveries;
    return _deliveries.where((d) => d.status == status).toList();
  }

  static Future<List<Delivery>> filterByScoreRange(
      double minScore, double maxScore) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _deliveries.where((d) {
      final score = d.addressVerification?.confidenceScore;
      if (score == null) return false;
      return score >= minScore && score <= maxScore;
    }).toList();
  }

  static Future<List<Delivery>> filterDeliveries({
    DeliveryStatus? status,
    double? minScore,
    double? maxScore,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var result = List<Delivery>.from(_deliveries);

    if (status != null) {
      result = result.where((d) => d.status == status).toList();
    }

    if (minScore != null || maxScore != null) {
      result = result.where((d) {
        final score = d.addressVerification?.confidenceScore;
        if (score == null) return false;
        if (minScore != null && score < minScore) return false;
        if (maxScore != null && score > maxScore) return false;
        return true;
      }).toList();
    }

    if (startDate != null) {
      result = result
          .where((d) => d.scheduledDate.isAfter(startDate))
          .toList();
    }

    if (endDate != null) {
      result = result
          .where((d) => d.scheduledDate.isBefore(endDate.add(const Duration(days: 1))))
          .toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((d) {
        return d.customerName.toLowerCase().contains(query) ||
            d.rawAddress.toLowerCase().contains(query) ||
            d.id.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  static Future<void> updateDelivery(Delivery delivery) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _deliveries.indexWhere((d) => d.id == delivery.id);
    if (index != -1) {
      _deliveries[index] = delivery;
    }
  }
}
