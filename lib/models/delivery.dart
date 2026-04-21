import 'address_verification.dart';
import 'feedback.dart';

enum DeliveryStatus { pending, inProgress, completed, failed }

class Delivery {
  final String id;
  final String? deliveryCode;
  final String customerName;
  final String customerPhone;
  final String rawAddress;
  final DeliveryStatus status;
  final DateTime scheduledDate;
  final AddressVerification? addressVerification;
  final DeliveryFeedback? feedback;
  final int riskFlagsCount;

  Delivery({
    required this.id,
    this.deliveryCode,
    required this.customerName,
    required this.customerPhone,
    required this.rawAddress,
    required this.status,
    required this.scheduledDate,
    this.addressVerification,
    this.feedback,
    this.riskFlagsCount = 0,
  });

  Delivery copyWith({
    String? id,
    String? deliveryCode,
    String? customerName,
    String? customerPhone,
    String? rawAddress,
    DeliveryStatus? status,
    DateTime? scheduledDate,
    AddressVerification? addressVerification,
    DeliveryFeedback? feedback,
    int? riskFlagsCount,
  }) {
    return Delivery(
      id: id ?? this.id,
      deliveryCode: deliveryCode ?? this.deliveryCode,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      rawAddress: rawAddress ?? this.rawAddress,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      addressVerification: addressVerification ?? this.addressVerification,
      feedback: feedback ?? this.feedback,
      riskFlagsCount: riskFlagsCount ?? this.riskFlagsCount,
    );
  }

  /// Maps a backend delivery object to a [Delivery].
  ///
  /// Backend fields:
  ///   id (int), address (string), status (string), scheduled_date (ISO8601),
  ///   confidence_score (double?), normalized_address (string?)
  factory Delivery.fromJson(Map<String, dynamic> json) {
    // Parse status string → DeliveryStatus enum
    final statusMap = {
      'pending': DeliveryStatus.pending,
      'in_progress': DeliveryStatus.inProgress,
      'completed': DeliveryStatus.completed,
      'failed': DeliveryStatus.failed,
      'delivered': DeliveryStatus.completed,
      'cancelled': DeliveryStatus.failed,
    };
    final status = statusMap[json['status']] ?? DeliveryStatus.pending;

    // Build a lightweight AddressVerification if the backend supplied
    // confidence_score or normalized_address for this delivery.
    AddressVerification? verification;
    final double? confidenceScore =
        (json['confidence_score'] as num?)?.toDouble();
    final String? normalizedAddress =
        json['normalized_address'] as String?;
    final double? latitude = (json['latitude'] as num?)?.toDouble();
    final double? longitude = (json['longitude'] as num?)?.toDouble();

    if (confidenceScore != null || normalizedAddress != null) {
      verification = AddressVerification(
        id: json['id']?.toString() ?? '',
        rawAddress: json['address']?.toString() ?? '',
        normalizedAddress: normalizedAddress ?? '',
        confidenceScore: confidenceScore ?? 0.0,
        matchDetails: json['match_details']?.toString() ?? '',
        detectedEntities: json['detected_entities'] != null
            ? DetectedEntities.fromJson(json['detected_entities'] as Map<String, dynamic>)
            : DetectedEntities(),
        riskFlags: json['risk_flags'] != null
            ? (json['risk_flags'] as List)
                .map((e) => RiskFlag.fromJson(e as Map<String, dynamic>))
                .toList()
            : [],
        createdAt: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
      );
    }

    final int riskFlagsCount = json['risk_flags_count'] as int? ?? 0;

    return Delivery(
      id: json['id'].toString(),
      deliveryCode: json['delivery_code'] as String?,
      customerName: json['customer_name'] as String? ?? '',
      customerPhone: json['customer_phone'] as String? ?? '',
      rawAddress: json['address'] as String? ?? '',
      status: status,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      addressVerification: verification,
      riskFlagsCount: riskFlagsCount,
    );
  }

  String get statusLabel {
    switch (status) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.inProgress:
        return 'In Progress';
      case DeliveryStatus.completed:
        return 'Completed';
      case DeliveryStatus.failed:
        return 'Failed';
    }
  }
}
