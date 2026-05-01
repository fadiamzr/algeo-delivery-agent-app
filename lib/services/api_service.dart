import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use localhost for local development (Chrome/Web). Use 10.0.2.2 for Android Emulator.
  // Using Render production URL for APK builds
  static const String baseUrl = 'https://algeo-verify.onrender.com';

  // ── Token persistence ──────────────────────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // ── Headers ────────────────────────────────────────────────────────────────

  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ── GET ───────────────────────────────────────────────────────────────────

  static Future<http.Response> get(String path) async {
    final headers = await authHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      await clearToken();
      throw Exception('SESSION_EXPIRED');
    }

    return response;
  }

  // ── POST ──────────────────────────────────────────────────────────────────

  static Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await authHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      await clearToken();
      throw Exception('SESSION_EXPIRED');
    }

    return response;
  }

  // ── PATCH ─────────────────────────────────────────────────────────────────

  static Future<http.Response> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await authHeaders();

    final response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      await clearToken();
      throw Exception('SESSION_EXPIRED');
    }

    return response;
  }

  // ── UNAUTHORIZED HANDLER ──────────────────────────────────────────────────

  static void handleUnauthorized(context) {
    // Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }
}
