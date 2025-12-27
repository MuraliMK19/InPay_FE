import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.0.2.2:8765";
  final _storage = const FlutterSecureStorage();

  // --- STORE THE TOKEN ---
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // --- RETRIEVE THE TOKEN ---
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // --- DELETE THE TOKEN (Logout) ---
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<bool> login(String userid, String password) async {
    final url = Uri.parse("$baseUrl/api/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userid": userid, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return true;
    } else {
      throw Exception("Login failed");
    }
  }

  // inside your lib/services/api_service.dart

  Future<Map<String, dynamic>?> fetchBalance() async {
    try {
      // 1. Retrieve the token you saved during Login
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/balance'),
        headers: {
          'Content-Type': 'application/json',
          // 2. Add the Bearer token exactly like we did in Postman
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to fetch balance: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<dynamic>?> fetchTransactions() async {
    try {
      // 1. Get the saved JWT token
      final token = await _storage.read(key: 'jwt_token');

      // 2. Call your Go Backend
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/transactions'),
            headers: {
              'Authorization':
                  'Bearer $token', // The "Passport" for the request
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // 3. Convert the JSON string into a Dart List
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        debugPrint("Server Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Network Error: $e");
      return null;
    }
  }
}
