import '../models/user.dart';

class MockUsers {
  static final User deliveryAgent = User(
    id: 'agent-001',
    name: 'Karim Benali',
    email: 'karim.benali@algeo.dz',
    role: 'delivery_agent',
    createdAt: DateTime(2025, 6, 15),
  );

  static const String mockEmail = 'karim.benali@algeo.dz';
  static const String mockPassword = 'agent123';
  static const String mockToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock-jwt-token';
}
