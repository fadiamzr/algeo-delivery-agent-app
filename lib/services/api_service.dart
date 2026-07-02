import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://algeo-verify.onrender.com';
  static const _storage = FlutterSecureStorage();

  // ── Token persistence ──────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
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