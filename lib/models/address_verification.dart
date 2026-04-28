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
      wilaya: json['wilaya']?.toString(),
      commune: json['commune']?.toString(),
      postalCode: json['postal_code'] != null
          ? int.tryParse(json['postal_code'].toString())
          : (json['postalCode'] != null ? int.tryParse(json['postalCode'].toString()) : null),
      street: json['street']?.toString(),
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
  final double? latitude;
  final double? longitude;

  AddressVerification({
    required this.id,
    required this.rawAddress,
    required this.normalizedAddress,
    required this.confidenceScore,
    required this.matchDetails,
    required this.detectedEntities,
    required this.riskFlags,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  factory AddressVerification.fromJson(Map<String, dynamic> json) {
    // detectedEntities may be null when backend skips entity extraction
    DetectedEntities entities;
    final entitiesJson = json['detected_entities'] ?? json['detectedEntities'];
    if (entitiesJson != null) {
      entities = DetectedEntities.fromJson(
          entitiesJson as Map<String, dynamic>);
    } else {
      entities = DetectedEntities();
    }

    // riskFlags may be null — default to empty list
    List<RiskFlag> flags = [];
    final flagsJson = json['risk_flags'] ?? json['riskFlags'];
    if (flagsJson != null) {
      flags = (flagsJson as List)
          .map((e) => RiskFlag.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final createdAtStr = json['created_at'] ?? json['createdAt'];

    return AddressVerification(
      id: json['id']?.toString() ?? '',
      rawAddress: (json['raw_address'] ?? json['rawAddress'])?.toString() ?? '',
      normalizedAddress: (json['normalized_address'] ?? json['normalizedAddress'])?.toString() ?? '',
      confidenceScore:
          ((json['confidence_score'] ?? json['confidenceScore']) as num?)?.toDouble() ?? 0.0,
      matchDetails: (json['match_details'] ?? json['matchDetails'])?.toString() ?? '',
      detectedEntities: entities,
      riskFlags: flags,
      createdAt: createdAtStr != null
          ? DateTime.parse(createdAtStr.toString())
          : DateTime.now(),
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
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
      label: json['label']?.toString() ?? '',
      severity: RiskSeverity.values.firstWhere(
          (e) => e.name.toLowerCase() == (json['severity'] ?? '').toString().toLowerCase(),
          orElse: () => RiskSeverity.low),
      description: json['description']?.toString() ?? '',
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
