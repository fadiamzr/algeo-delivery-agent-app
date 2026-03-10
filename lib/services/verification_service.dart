import 'dart:math';
import '../models/address_verification.dart';
import '../mock_data/mock_verifications.dart';

class VerificationService {
  /// Simulates the full verification flow from the sequence diagram:
  /// normalize(rawAddress) → detect_entities → compute_score → save → return result
  static Future<AddressVerification> verifyAddress(String rawAddress) async {
    // Step 1: Normalize (simulate delay)
    await Future.delayed(const Duration(milliseconds: 600));
    final normalized = _normalize(rawAddress);

    // Step 2: Detect entities
    await Future.delayed(const Duration(milliseconds: 400));
    final entities = _detectEntities(normalized);

    // Step 3: Compute confidence score
    await Future.delayed(const Duration(milliseconds: 300));
    final score = _computeScore(entities);

    // Step 4: Generate risk flags
    final riskFlags = _generateRiskFlags(rawAddress, entities, score);

    // Step 5: Build result
    final verification = AddressVerification(
      id: 'VER-${DateTime.now().millisecondsSinceEpoch}',
      rawAddress: rawAddress,
      normalizedAddress: normalized,
      confidenceScore: score,
      matchDetails: _generateMatchDetails(score, entities),
      detectedEntities: entities,
      riskFlags: riskFlags,
      createdAt: DateTime.now(),
    );

    return verification;
  }

  static String _normalize(String rawAddress) {
    var normalized = rawAddress.trim();
    // Simple normalization: capitalize, standardize abbreviations
    normalized = normalized.replaceAll('Blvd', 'Boulevard');
    normalized = normalized.replaceAll('blvd', 'Boulevard');
    normalized = normalized.replaceAll('Ave', 'Avenue');
    normalized = normalized.replaceAll('ave', 'Avenue');
    normalized = normalized.replaceAll('Bt ', 'Bâtiment ');
    normalized = normalized.replaceAll('bt ', 'Bâtiment ');

    // Capitalize first letter of each word
    normalized = normalized.split(' ').map((w) {
      if (w.isEmpty) return w;
      if (['du', 'de', 'la', 'le', 'les', 'des', 'el', 'et', 'à', 'au']
          .contains(w.toLowerCase())) {
        return w.toLowerCase();
      }
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');

    return normalized;
  }

  static DetectedEntities _detectEntities(String normalized) {
    final wilayas = [
      'Alger', 'Oran', 'Constantine', 'Batna', 'Tizi-Ouzou',
      'Blida', 'Sétif', 'Annaba', 'Béjaïa', 'Djelfa', 'Chlef',
    ];
    final lowerNormalized = normalized.toLowerCase();

    String? detectedWilaya;
    for (final w in wilayas) {
      if (lowerNormalized.contains(w.toLowerCase())) {
        detectedWilaya = w;
        break;
      }
    }

    // Extract simple postal code heuristic
    final postalMatch = RegExp(r'\b(\d{5})\b').firstMatch(normalized);
    int? postalCode;
    if (postalMatch != null) {
      postalCode = int.tryParse(postalMatch.group(1)!);
    }

    // Extract street using "Rue", "Avenue", "Boulevard" prefix
    String? street;
    final streetMatch = RegExp(r'((?:Rue|Avenue|Boulevard|Cité|Hai|Quartier)[^,]+)')
        .firstMatch(normalized);
    if (streetMatch != null) {
      street = streetMatch.group(1)?.trim();
    }

    return DetectedEntities(
      wilaya: detectedWilaya,
      commune: detectedWilaya, // simplified: commune = wilaya for mock
      postalCode: postalCode,
      street: street,
    );
  }

  static double _computeScore(DetectedEntities entities) {
    double score = 0.0;
    const wilayaWeight = 0.3;
    const communeWeight = 0.25;
    const postalWeight = 0.2;
    const streetWeight = 0.25;

    if (entities.wilaya != null) score += wilayaWeight;
    if (entities.commune != null) score += communeWeight;
    if (entities.postalCode != null) score += postalWeight;
    if (entities.street != null) score += streetWeight;

    // Add small randomness for realism
    final random = Random();
    score += (random.nextDouble() * 0.1) - 0.05;
    return score.clamp(0.0, 1.0);
  }

  static List<RiskFlag> _generateRiskFlags(
      String rawAddress, DetectedEntities entities, double score) {
    final flags = <RiskFlag>[];

    if (entities.street == null) {
      flags.add(RiskFlag(
        label: 'No Street Name',
        severity: RiskSeverity.high,
        description: 'No specific street name found in address',
      ));
    }

    if (entities.postalCode == null) {
      flags.add(RiskFlag(
        label: 'Missing Postal Code',
        severity: RiskSeverity.medium,
        description: 'No postal code detected in address',
      ));
    }

    if (rawAddress.contains('près') ||
        rawAddress.contains('derrière') ||
        rawAddress.contains('en face') ||
        rawAddress.contains('à côté')) {
      flags.add(RiskFlag(
        label: 'Landmark Reference',
        severity: RiskSeverity.high,
        description: 'Address uses relative landmarks instead of precise location',
      ));
    }

    if (!RegExp(r'\d').hasMatch(rawAddress)) {
      flags.add(RiskFlag(
        label: 'No Street Number',
        severity: RiskSeverity.medium,
        description: 'Address does not contain a street number',
      ));
    }

    if (entities.wilaya == null) {
      flags.add(RiskFlag(
        label: 'Unknown Wilaya',
        severity: RiskSeverity.high,
        description: 'Could not determine the wilaya from the address',
      ));
    }

    return flags;
  }

  static String _generateMatchDetails(double score, DetectedEntities entities) {
    if (score >= 0.9) return 'All components matched successfully';
    if (score >= 0.7) return 'Most components matched, minor issues detected';
    if (score >= 0.5) return 'Partial match, some components missing or ambiguous';
    return 'Poor match, significant address components missing';
  }

  static Future<List<VerificationRecord>> getVerificationHistory() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockVerifications.getHistory();
  }
}
