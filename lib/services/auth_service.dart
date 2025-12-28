import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final String baseUrl = dotenv.env['BACKEND_URL']!;
  static final String googleClientId = dotenv.env['WEB_GOOGLE_CLIENT_ID']!;

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    final result = _processResponse(response);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', data['email']);

    return result;
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> verifyOtp(String code) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');

    if (email == null || email.isEmpty) {
      throw Exception("Session expired. Please sign up again.");
    }

    print("Flutter Debug: Verifying $email with code $code");

    final response = await http.post(
      Uri.parse('$baseUrl/user/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'verificationCode': code.trim(),
      }),
    );

    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> resendOtp() async {
    final email = await getStoredEmail();
    final response = await http.post(
      Uri.parse('$baseUrl/user/resend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> recoverPassword(
    String newPass,
    String confirmPass,
  ) async {
    final email = await getStoredEmail();
    final response = await http.post(
      Uri.parse('$baseUrl/user/recover'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': newPass,
        'confirmPassword': confirmPass,
      }),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> googleSignIn() async {
    try {
      await _googleSignIn.initialize(serverClientId: googleClientId);

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled by the user');
      }

      const List<String> scopes = ['email', 'profile'];

      final GoogleSignInClientAuthorization? authorization = await googleUser
          .authorizationClient
          ?.authorizationForScopes(scopes);

      final String? accessToken = authorization?.accessToken;

      if (accessToken == null) {
        throw Exception('Failed to obtain Google access token');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/user/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': accessToken}),
      );

      final data = _processResponse(response);

      await saveUser(data['token'], googleUser.email);

      return data;
    } catch (e) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final email = prefs.getString('email');

    final response = await http.get(
      Uri.parse('$baseUrl/display?email=$email'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _processResponse(response);
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'Server error');
    }
  }

  static Future<void> saveUser(String token, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('email', email);
  }

  static Future<String?> getStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  static Future<Map<String, String?>> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'email': prefs.getString('email'),
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
    await prefs.remove('fname');
    await prefs.remove('lname');

    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google sign-out error: $e');
    }
  }
}
