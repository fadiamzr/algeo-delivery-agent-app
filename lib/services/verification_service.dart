import 'dart:convert';
import '../models/address_verification.dart';
import 'api_service.dart';

class VerificationService {
  /// Calls the backend `POST /verify` endpoint to perform real address
  /// verification (normalization → entity detection → confidence scoring).
  ///
  /// Always returns a valid [AddressVerification] — never throws to the UI.
  static Future<AddressVerification> verifyAddress(String rawAddress) async {
    try {
      final response = await ApiService.post(
        '/verify',
        body: {'raw_address': rawAddress},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        return AddressVerification.fromJson(json);
      } else {
        return _fallback(rawAddress, 'Server error (${response.statusCode})');
      }
    } catch (e) {
      return _fallback(rawAddress, e.toString());
    }
  }

  /// Returns a safe default [AddressVerification] so the UI never crashes.
  static AddressVerification _fallback(String rawAddress, String reason) {
    return AddressVerification(
      id: '',
      rawAddress: rawAddress,
      normalizedAddress: rawAddress,
      confidenceScore: 0.0,
      matchDetails: 'Verification unavailable: $reason',
      detectedEntities: DetectedEntities(),
      riskFlags: const [],
      createdAt: DateTime.now(),
    );
  }

  static Future<List<VerificationRecord>> getVerificationHistory() async {
    try {
      final response = await ApiService.get('/verifications/history');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((item) {
          final map = item as Map<String, dynamic>;
          return VerificationRecord(
            id: map['id']?.toString() ?? '',
            verificationDate: map['createdAt'] != null
                ? DateTime.parse(map['createdAt'].toString())
                : DateTime.now(),
            resultScore:
                (map['confidenceScore'] as num?)?.toDouble() ?? 0.0,
            rawAddress: map['rawAddress']?.toString() ?? '',
            normalizedAddress: map['normalizedAddress']?.toString() ?? '',
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveVerificationToDelivery({
    required String deliveryId,
    required double confidenceScore,
    required String normalizedAddress,
    double? latitude,
    double? longitude,
  }) async {
    final payload = <String, dynamic>{
      'confidence_score': confidenceScore,
      'normalized_address': normalizedAddress,
    };
    if (latitude != null) payload['latitude'] = latitude;
    if (longitude != null) payload['longitude'] = longitude;

    final response = await ApiService.patch(
      '/deliveries/$deliveryId/verification',
      body: payload,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('SESSION_EXPIRED');
    } else {
      throw Exception('Failed to save verification result: ${response.body}');
    }
  }
}
