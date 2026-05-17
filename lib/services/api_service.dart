import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // ==================== AUTH ====================

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile(int userId, String name) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/update-profile/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> updatePassword(int userId, String oldPassword, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/update-password/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'oldPassword': oldPassword, 'newPassword': newPassword}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ==================== TASKS ====================

  static Future<List<dynamic>> getTasks(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/$userId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> addTask({
    required int userId,
    required String name,
    String? deadline,
    String? submissionLink,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'name': name,
          'deadline': deadline,
          'submission_link': submissionLink,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> updateTask({
    required int id,
    required String name,
    String? deadline,
    required bool isDone,
    String? submissionLink,
    String? completedAt,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'deadline': deadline,
          'is_done': isDone,
          'submission_link': submissionLink,
          'completed_at': completedAt,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> deleteTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$id'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Tidak dapat terhubung ke server'};
    }
  }
}