import 'address_verification.dart';
import 'feedback.dart';

enum DeliveryStatus { pending, inProgress, completed, failed }

class Delivery {
  final String id;
  final String customerName;
  final String customerPhone;
  final String rawAddress;
  final DeliveryStatus status;
  final DateTime scheduledDate;
  final AddressVerification? addressVerification;
  final DeliveryFeedback? feedback;

  Delivery({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.rawAddress,
    required this.status,
    required this.scheduledDate,
    this.addressVerification,
    this.feedback,
  });

  Delivery copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? rawAddress,
    DeliveryStatus? status,
    DateTime? scheduledDate,
    AddressVerification? addressVerification,
    DeliveryFeedback? feedback,
  }) {
    return Delivery(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      rawAddress: rawAddress ?? this.rawAddress,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      addressVerification: addressVerification ?? this.addressVerification,
      feedback: feedback ?? this.feedback,
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
