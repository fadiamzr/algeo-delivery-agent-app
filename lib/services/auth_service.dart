import '../models/user.dart';
import '../mock_data/mock_users.dart';

class AuthService {
  static User? _currentUser;
  static String? _token;

  static bool get isLoggedIn => _currentUser != null;
  static User? get currentUser => _currentUser;
  static String? get token => _token;

  static Future<User> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (email == MockUsers.mockEmail && password == MockUsers.mockPassword) {
      _currentUser = MockUsers.deliveryAgent;
      _token = MockUsers.mockToken;
      return _currentUser!;
    }

    throw Exception('Invalid email or password');
  }

  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _token = null;
  }

  static Future<bool> validateToken(String token) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return token == MockUsers.mockToken;
  }
}
