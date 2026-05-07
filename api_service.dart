import 'dart:convert';
import 'package:http/http.dart' as http;

// 💡 Laptop par testing ke liye:
// Chrome/Windows: http://127.0.0.1:8081
// Android Emulator: http://10.0.2.2:8081
const String baseUrl = "http://127.0.0.1:8081";

class ApiService {
  // ================== AUTHENTICATION ==================

  static Future<Map<String, dynamic>> login(String enrollment, String password,
      {String role = "Student"}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'enrollment': enrollment, 'password': password, 'role': role}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Server connectivity issue"};
    }
  }

  static Future<Map<String, dynamic>> signup(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add-student'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Signup failed"};
    }
  }

  // ================== TEACHER ACTIONS ==================

  static Future<List<dynamic>> getStudents(String dept, String course) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-students/$dept'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> submitAttendance({
    required String course,
    required String date,
    required List<Map<String, String>> attendanceData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit-attendance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'course': course, 'date': date, 'attendance': attendanceData}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Submission failed"};
    }
  }

  // ================== STUDENT ACTIONS ==================

  // ✅ Updated to match backend registration logic
  static Future<Map<String, dynamic>> submitRegistration({
    required String enrollment,
    required String course,
    required String phone,
    required String semester,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit-registration'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'enrollment': enrollment,
          'course': course,
          'phone': phone,
          'semester': semester,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Registration failed: $e"};
    }
  }
// ================== TEACHER ACTIONS ==================

  static Future<Map<String, dynamic>> postAnnouncement({
    required String dept,
    required String course,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/post-announcement'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dept': dept,
          'course': course,
          'content': content,
          'date': DateTime.now().toIso8601String(),
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Failed to post announcement: $e"};
    }
  }

  // ✅ New: Get available courses specifically for the registration dropdown
  static Future<List<dynamic>> getAvailableCourses(String enrollment) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-available-courses/$enrollment'),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      print("Error fetching available courses: $e");
      return [];
    }
  }

  static Future<List<dynamic>> getCourses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-all-courses'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getAttendance(String enrollment) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/get-attendance/$enrollment'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      print("Error fetching attendance: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> getProfile(String enrollment) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/get-profile/$enrollment'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"status": "error", "message": "Profile not found"};
    } catch (e) {
      return {"status": "error", "message": "Error loading profile: $e"};
    }
  }

  static Future<List<dynamic>> getGrades(String enrollment) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/grades/$enrollment'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getInstructors() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-instructors'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getAttendanceSummary(String enrollment) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-attendance-summary/$enrollment'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching summary: $e");
      return [];
    }
  }
}
