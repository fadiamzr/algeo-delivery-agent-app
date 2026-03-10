class DetectedEntities {
  final String? wilaya;
  final String? commune;
  final int? postalCode;
  final String? street;

  DetectedEntities({
    this.wilaya,
    this.commune,
    this.postalCode,
    this.street,
  });

  factory DetectedEntities.fromJson(Map<String, dynamic> json) {
    return DetectedEntities(
      wilaya: json['wilaya'],
      commune: json['commune'],
      postalCode: json['postalCode'],
      street: json['street'],
    );
  }

  Map<String, dynamic> toJson() => {
        'wilaya': wilaya,
        'commune': commune,
        'postalCode': postalCode,
        'street': street,
      };
}

class AddressVerification {
  final String id;
  final String rawAddress;
  final String normalizedAddress;
  final double confidenceScore;
  final String matchDetails;
  final DetectedEntities detectedEntities;
  final List<RiskFlag> riskFlags;
  final DateTime createdAt;

  AddressVerification({
    required this.id,
    required this.rawAddress,
    required this.normalizedAddress,
    required this.confidenceScore,
    required this.matchDetails,
    required this.detectedEntities,
    required this.riskFlags,
    required this.createdAt,
  });

  factory AddressVerification.fromJson(Map<String, dynamic> json) {
    return AddressVerification(
      id: json['id'],
      rawAddress: json['rawAddress'],
      normalizedAddress: json['normalizedAddress'],
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      matchDetails: json['matchDetails'],
      detectedEntities: DetectedEntities.fromJson(json['detectedEntities']),
      riskFlags: (json['riskFlags'] as List)
          .map((e) => RiskFlag.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class RiskFlag {
  final String label;
  final RiskSeverity severity;
  final String description;

  RiskFlag({
    required this.label,
    required this.severity,
    required this.description,
  });

  factory RiskFlag.fromJson(Map<String, dynamic> json) {
    return RiskFlag(
      label: json['label'],
      severity: RiskSeverity.values.firstWhere(
          (e) => e.name == json['severity'],
          orElse: () => RiskSeverity.low),
      description: json['description'],
    );
  }
}

enum RiskSeverity { low, medium, high }

class VerificationRecord {
  final String id;
  final DateTime verificationDate;
  final double resultScore;
  final String rawAddress;
  final String normalizedAddress;

  VerificationRecord({
    required this.id,
    required this.verificationDate,
    required this.resultScore,
    required this.rawAddress,
    required this.normalizedAddress,
  });
}
