import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static User? _currentUser;
  static String? _token;

  static bool get isLoggedIn => _currentUser != null;
  static User? get currentUser => _currentUser;
  static String? get token => _token;

  static Future<User> login(String rawEmail, String rawPassword) async {
    final email = rawEmail.trim();
    final password = rawPassword.trim();

    final uri = Uri.parse('${ApiService.baseUrl}/auth/login');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body;
        try {
          body = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          throw Exception('Failed to decode JSON response');
        }

        final accessToken = body['access_token']?.toString();
        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('Access token missing from response');
        }

        await ApiService.saveToken(accessToken);
        _token = accessToken;

        _currentUser = User(
          id: body['user_id']?.toString() ?? '1',
          name: body['name']?.toString() ?? email.split('@').first,
          email: email,
          role: body['role']?.toString() ?? 'agent',
          createdAt: DateTime.now(),
        );
        return _currentUser!;
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        throw Exception('Invalid email or password');
      } else {
        throw Exception(
          'Server error (${response.statusCode}): ${response.body}',
        );
      }
    } on http.ClientException {
      throw Exception('Network error: Could not connect to the server');
    } on TimeoutException {
      throw Exception('Network error: Connection timed out');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  static Future<void> logout() async {
    await ApiService.clearToken();
    _currentUser = null;
    _token = null;
  }

  static Future<User> fetchCurrentUser() async {
    final response = await ApiService.get('/auth/me');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _currentUser = User(
        id: body['id']?.toString() ?? _currentUser?.id ?? '1',
        name:
            body['name']?.toString() ?? _currentUser?.name ?? 'Delivery Agent',
        email: body['email']?.toString() ?? _currentUser?.email ?? '',
        role: body['role']?.toString() ?? _currentUser?.role ?? 'agent',
        createdAt: body['created_at'] != null
            ? DateTime.parse(body['created_at'].toString())
            : DateTime.now(),
      );
      return _currentUser!;
    } else {
      throw Exception('Failed to fetch profile: ${response.statusCode}');
    }
  }

  static Future<bool> validateToken(String token) async {
    final stored = await ApiService.getToken();
    return stored != null && stored == token;
  }
}
