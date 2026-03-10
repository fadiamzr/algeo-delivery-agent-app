import '../models/delivery.dart';
import '../models/address_verification.dart';
import '../models/feedback.dart';

class MockDeliveries {
  static List<Delivery> getDeliveries() {
    return [
      Delivery(
        id: 'DEL-001',
        customerName: 'Amina Boudiaf',
        customerPhone: '+213 555 123 456',
        rawAddress: '12 Rue Didouche Mourad, Alger Centre, Alger',
        status: DeliveryStatus.pending,
        scheduledDate: DateTime.now().add(const Duration(hours: 2)),
        addressVerification: AddressVerification(
          id: 'VER-001',
          rawAddress: '12 Rue Didouche Mourad, Alger Centre, Alger',
          normalizedAddress: '12 Rue Didouche Mourad, Alger-Centre, Wilaya d\'Alger, 16000',
          confidenceScore: 0.92,
          matchDetails: 'All components matched successfully',
          detectedEntities: DetectedEntities(
            wilaya: 'Alger',
            commune: 'Alger-Centre',
            postalCode: 16000,
            street: 'Rue Didouche Mourad',
          ),
          riskFlags: [],
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ),
      Delivery(
        id: 'DEL-002',
        customerName: 'Youcef Khedira',
        customerPhone: '+213 555 234 567',
        rawAddress: '45 Blvd Mohamed V, Oran',
        status: DeliveryStatus.inProgress,
        scheduledDate: DateTime.now().add(const Duration(hours: 1)),
        addressVerification: AddressVerification(
          id: 'VER-002',
          rawAddress: '45 Blvd Mohamed V, Oran',
          normalizedAddress: '45 Boulevard Mohamed V, Oran, Wilaya d\'Oran, 31000',
          confidenceScore: 0.85,
          matchDetails: 'Street type abbreviated, corrected to full form',
          detectedEntities: DetectedEntities(
            wilaya: 'Oran',
            commune: 'Oran',
            postalCode: 31000,
            street: 'Boulevard Mohamed V',
          ),
          riskFlags: [
            RiskFlag(
              label: 'Abbreviation Detected',
              severity: RiskSeverity.low,
              description: 'Street type was abbreviated (Blvd → Boulevard)',
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ),
      Delivery(
        id: 'DEL-003',
        customerName: 'Fatima Zerhouni',
        customerPhone: '+213 555 345 678',
        rawAddress: 'Cité 500 Logements, Bt C, Batna',
        status: DeliveryStatus.pending,
        scheduledDate: DateTime.now().add(const Duration(hours: 4)),
        addressVerification: AddressVerification(
          id: 'VER-003',
          rawAddress: 'Cité 500 Logements, Bt C, Batna',
          normalizedAddress: 'Cité 500 Logements, Bâtiment C, Batna, Wilaya de Batna, 05000',
          confidenceScore: 0.67,
          matchDetails: 'Commune matched, building number ambiguous',
          detectedEntities: DetectedEntities(
            wilaya: 'Batna',
            commune: 'Batna',
            postalCode: 05000,
            street: 'Cité 500 Logements, Bâtiment C',
          ),
          riskFlags: [
            RiskFlag(
              label: 'Ambiguous Building',
              severity: RiskSeverity.medium,
              description: 'Building identifier "Bt C" is ambiguous and could refer to multiple buildings',
            ),
            RiskFlag(
              label: 'Missing Postal Code',
              severity: RiskSeverity.low,
              description: 'Postal code was inferred from commune name',
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ),
      Delivery(
        id: 'DEL-004',
        customerName: 'Mohamed Saidi',
        customerPhone: '+213 555 456 789',
        rawAddress: 'Hai el Badr, près du marché, Constantine',
        status: DeliveryStatus.failed,
        scheduledDate: DateTime.now().subtract(const Duration(hours: 1)),
        addressVerification: AddressVerification(
          id: 'VER-004',
          rawAddress: 'Hai el Badr, près du marché, Constantine',
          normalizedAddress: 'Hai El Badr, Constantine, Wilaya de Constantine, 25000',
          confidenceScore: 0.38,
          matchDetails: 'Landmark-based description, no street number, imprecise location',
          detectedEntities: DetectedEntities(
            wilaya: 'Constantine',
            commune: 'Constantine',
            postalCode: 25000,
            street: 'Hai El Badr',
          ),
          riskFlags: [
            RiskFlag(
              label: 'No Street Number',
              severity: RiskSeverity.high,
              description: 'Address lacks a specific street number',
            ),
            RiskFlag(
              label: 'Landmark Reference',
              severity: RiskSeverity.high,
              description: 'Address uses landmark "près du marché" instead of proper address',
            ),
            RiskFlag(
              label: 'Imprecise Location',
              severity: RiskSeverity.medium,
              description: 'Address cannot be geocoded to a specific location',
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ),
      Delivery(
        id: 'DEL-005',
        customerName: 'Rachid Hamidi',
        customerPhone: '+213 555 567 890',
        rawAddress: '8 Rue des Frères Bouadou, Tizi Ouzou',
        status: DeliveryStatus.completed,
        scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
        addressVerification: AddressVerification(
          id: 'VER-005',
          rawAddress: '8 Rue des Frères Bouadou, Tizi Ouzou',
          normalizedAddress: '8 Rue des Frères Bouadou, Tizi-Ouzou, Wilaya de Tizi-Ouzou, 15000',
          confidenceScore: 0.95,
          matchDetails: 'Perfect match on all components',
          detectedEntities: DetectedEntities(
            wilaya: 'Tizi-Ouzou',
            commune: 'Tizi-Ouzou',
            postalCode: 15000,
            street: 'Rue des Frères Bouadou',
          ),
          riskFlags: [],
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        ),
        feedback: DeliveryFeedback(
          id: 'FB-005',
          outcome: FeedbackOutcome.delivered,
          notes: 'Delivered successfully. Customer was present.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ),
      Delivery(
        id: 'DEL-006',
        customerName: 'Nadia Benmansour',
        customerPhone: '+213 555 678 901',
        rawAddress: 'Lotissement n° 23, Zone Industrielle, Sétif',
        status: DeliveryStatus.pending,
        scheduledDate: DateTime.now().add(const Duration(hours: 6)),
      ),
      Delivery(
        id: 'DEL-007',
        customerName: 'Ahmed Taleb',
        customerPhone: '+213 555 789 012',
        rawAddress: '17 Avenue 1er Novembre, Blida',
        status: DeliveryStatus.completed,
        scheduledDate: DateTime.now().subtract(const Duration(days: 2)),
        addressVerification: AddressVerification(
          id: 'VER-007',
          rawAddress: '17 Avenue 1er Novembre, Blida',
          normalizedAddress: '17 Avenue du 1er Novembre 1954, Blida, Wilaya de Blida, 09000',
          confidenceScore: 0.88,
          matchDetails: 'Street name expanded; good match',
          detectedEntities: DetectedEntities(
            wilaya: 'Blida',
            commune: 'Blida',
            postalCode: 9000,
            street: 'Avenue du 1er Novembre 1954',
          ),
          riskFlags: [
            RiskFlag(
              label: 'Street Name Expanded',
              severity: RiskSeverity.low,
              description: 'Abbreviated street name was expanded to full form',
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
        ),
        feedback: DeliveryFeedback(
          id: 'FB-007',
          outcome: FeedbackOutcome.delivered,
          notes: 'Left with neighbor as customer was away.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ),
      Delivery(
        id: 'DEL-008',
        customerName: 'Sara Meziane',
        customerPhone: '+213 555 890 123',
        rawAddress: 'Quartier résidentiel, derrière la mosquée, Annaba',
        status: DeliveryStatus.inProgress,
        scheduledDate: DateTime.now(),
        addressVerification: AddressVerification(
          id: 'VER-008',
          rawAddress: 'Quartier résidentiel, derrière la mosquée, Annaba',
          normalizedAddress: 'Quartier Résidentiel, Annaba, Wilaya d\'Annaba, 23000',
          confidenceScore: 0.42,
          matchDetails: 'Very imprecise address, landmark-based',
          detectedEntities: DetectedEntities(
            wilaya: 'Annaba',
            commune: 'Annaba',
            postalCode: 23000,
          ),
          riskFlags: [
            RiskFlag(
              label: 'No Street Name',
              severity: RiskSeverity.high,
              description: 'No specific street name found in address',
            ),
            RiskFlag(
              label: 'Landmark Reference',
              severity: RiskSeverity.high,
              description: 'Uses landmark "derrière la mosquée" as reference',
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ),
    ];
  }
}
