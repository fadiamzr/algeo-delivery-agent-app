import '../models/address_verification.dart';

class MockVerifications {
  static List<VerificationRecord> getHistory() {
    return [
      VerificationRecord(
        id: 'VER-001',
        verificationDate: DateTime.now().subtract(const Duration(hours: 1)),
        resultScore: 0.92,
        rawAddress: '12 Rue Didouche Mourad, Alger Centre, Alger',
        normalizedAddress: '12 Rue Didouche Mourad, Alger-Centre, Wilaya d\'Alger, 16000',
      ),
      VerificationRecord(
        id: 'VER-002',
        verificationDate: DateTime.now().subtract(const Duration(hours: 2)),
        resultScore: 0.85,
        rawAddress: '45 Blvd Mohamed V, Oran',
        normalizedAddress: '45 Boulevard Mohamed V, Oran, Wilaya d\'Oran, 31000',
      ),
      VerificationRecord(
        id: 'VER-003',
        verificationDate: DateTime.now().subtract(const Duration(hours: 3)),
        resultScore: 0.67,
        rawAddress: 'Cité 500 Logements, Bt C, Batna',
        normalizedAddress: 'Cité 500 Logements, Bâtiment C, Batna, Wilaya de Batna, 05000',
      ),
      VerificationRecord(
        id: 'VER-004',
        verificationDate: DateTime.now().subtract(const Duration(hours: 5)),
        resultScore: 0.38,
        rawAddress: 'Hai el Badr, près du marché, Constantine',
        normalizedAddress: 'Hai El Badr, Constantine, Wilaya de Constantine, 25000',
      ),
      VerificationRecord(
        id: 'VER-005',
        verificationDate: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        resultScore: 0.95,
        rawAddress: '8 Rue des Frères Bouadou, Tizi Ouzou',
        normalizedAddress: '8 Rue des Frères Bouadou, Tizi-Ouzou, Wilaya de Tizi-Ouzou, 15000',
      ),
      VerificationRecord(
        id: 'VER-006',
        verificationDate: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        resultScore: 0.73,
        rawAddress: '3 Rue Larbi Ben M\'hidi, Bejaia',
        normalizedAddress: '3 Rue Larbi Ben M\'hidi, Béjaïa, Wilaya de Béjaïa, 06000',
      ),
      VerificationRecord(
        id: 'VER-007',
        verificationDate: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
        resultScore: 0.88,
        rawAddress: '17 Avenue 1er Novembre, Blida',
        normalizedAddress: '17 Avenue du 1er Novembre 1954, Blida, Wilaya de Blida, 09000',
      ),
      VerificationRecord(
        id: 'VER-008',
        verificationDate: DateTime.now().subtract(const Duration(minutes: 30)),
        resultScore: 0.42,
        rawAddress: 'Quartier résidentiel, derrière la mosquée, Annaba',
        normalizedAddress: 'Quartier Résidentiel, Annaba, Wilaya d\'Annaba, 23000',
      ),
      VerificationRecord(
        id: 'VER-009',
        verificationDate: DateTime.now().subtract(const Duration(days: 3)),
        resultScore: 0.79,
        rawAddress: '25 Rue du Stade, Djelfa',
        normalizedAddress: '25 Rue du Stade, Djelfa, Wilaya de Djelfa, 17000',
      ),
      VerificationRecord(
        id: 'VER-010',
        verificationDate: DateTime.now().subtract(const Duration(days: 4)),
        resultScore: 0.55,
        rawAddress: 'Près de l\'école, Chlef',
        normalizedAddress: 'Chlef, Wilaya de Chlef, 02000',
      ),
    ];
  }
}
