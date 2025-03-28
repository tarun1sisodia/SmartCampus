import 'dart:convert';

import 'package:http/http.dart' as http;

/// THttpHelper: A powerful and well-structured HTTP client wrapper
/// Features:
/// - Clean REST API implementation
/// - Centralized error handling
/// - Standardized response parsing
/// - Type-safe response handling
class THttpHelper {
  /// Base URL configuration for all API requests
  /// Centralized for easy maintenance and environment switching
  static const String _baseUrl = "https://www.github.com/tarun1sisodia";

  /// GET request implementation
  /// Perfect for fetching data, product listings, user profiles
  /// Returns parsed JSON response as Map
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(Uri.parse('$_baseUrl/$endpoint'));
    return _handleResponse(response);
  }

  /// POST request implementation
  /// Ideal for creating new resources, user authentication
  /// Automatically handles JSON encoding of request body
  static Future<Map<String, dynamic>> post(
    String endpoint,
    dynamic data,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {'Content-Type': 'applicatio/json'},
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  /// PUT request implementation
  /// Perfect for updating existing resources
  /// Handles JSON encoding automatically
  static Future<Map<String, dynamic>> put(String endpoint, dynamic data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  /// DELETE request implementation
  /// Clean way to remove resources
  /// Simple endpoint-only interface
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$endpoint'));
    return _handleResponse(response);
  }

  /// Centralized response handler
  /// Provides consistent error handling and response parsing
  /// Throws exception for non-200 status codes
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
