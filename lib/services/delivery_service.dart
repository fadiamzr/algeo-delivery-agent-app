import 'dart:convert';
import '../models/address_verification.dart';
import '../models/delivery.dart';
import 'api_service.dart';

class DeliveryService {
  static List<Delivery> _deliveries = [];

  static Future<List<Delivery>> getAssignedDeliveries() async {
    try {
      final response = await ApiService.get('/deliveries/');
      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      _deliveries = data
          .map((item) => Delivery.fromJson(item as Map<String, dynamic>))
          .toList();
      return _deliveries;
    } catch (e) {
      throw Exception('Failed to fetch deliveries: ${e.toString()}');
    }
  }

  static Future<Delivery?> getDeliveryById(String id) async {
    final response = await ApiService.get('/deliveries/$id');

    if (response.statusCode == 200) {
      var delivery = Delivery.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

      // We already get all the necessary verification data (including latitude and longitude)
      // from the GET /deliveries/{id} response via Delivery.fromJson.
      // Do not call POST /verify here as it re-runs the verification and lacks lat/lng.

      return delivery;
    } else if (response.statusCode == 404) {
      return null;
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    } else {
      throw Exception('Failed to load delivery');
    }
  }

  static Future<List<Delivery>> filterByStatus(DeliveryStatus? status) async {
    if (status == null) return _deliveries;
    return _deliveries.where((d) => d.status == status).toList();
  }

  static Future<List<Delivery>> filterByScoreRange(
      double minScore, double maxScore) async {
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
    String statusStr = 'pending';
    switch (delivery.status) {
      case DeliveryStatus.pending: statusStr = 'pending'; break;
      case DeliveryStatus.inProgress: statusStr = 'in_progress'; break;
      case DeliveryStatus.completed: statusStr = 'delivered'; break;
      case DeliveryStatus.failed: statusStr = 'cancelled'; break;
    }

    final response = await ApiService.patch('/deliveries/${delivery.id}/status', body: {
      'status': statusStr,
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final index = _deliveries.indexWhere((d) => d.id == delivery.id);
      if (index != -1) {
        _deliveries[index] = delivery;
      }
    } else if (response.statusCode == 401) {
      throw Exception('SESSION_EXPIRED');
    } else {
      throw Exception('Failed to update delivery');
    }
  }
}
