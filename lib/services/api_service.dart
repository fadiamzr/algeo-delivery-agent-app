import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.43.158:8000';

  // Debug: print active baseUrl on first class reference
  static final _init = () {
    debugPrint('[ApiService] baseUrl = $baseUrl');
    return true;
  }();
  // ignore: unused_field
  static final bool _initialized = _init;

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
    };
  }

  // ── HTTP helpers ───────────────────────────────────────────────────────────

  static Future<http.Response> get(String path) async {
    final headers = await authHeaders();
    final response = await http.get(Uri.parse('$baseUrl$path'), headers: headers);
    if (response.statusCode == 401) {
      await clearToken();
      throw Exception('SESSION_EXPIRED');
    }
    return response;
  }

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

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }

    final url = Uri.parse('$baseUrl/auth/login');
    final requestBody = jsonEncode({
      'email': trimmedEmail,
      'password': trimmedPassword,
    });

    debugPrint('Login Request Body: $requestBody');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    debugPrint('Login Response Status: ${response.statusCode}');
    debugPrint('Login Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final token = jsonResponse['access_token'];
      if (token != null) {
        await saveToken(token.toString());
      }
      return jsonResponse;
    } else {
      throw Exception('Login failed: ${response.statusCode} ${response.body}');
    }
  }

  static void handleUnauthorized(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }
}
