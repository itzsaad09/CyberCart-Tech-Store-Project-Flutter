import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final String baseUrl = dotenv.env['BACKEND_URL']!;
  static final String googleClientId = dotenv.env['WEB_GOOGLE_CLIENT_ID']!;

  // Singleton instance - no currentUser property anymore in v7+
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> verifyOtp(String code) async {
    final email = await getStoredEmail();
    final response = await http.post(
      Uri.parse('$baseUrl/user/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'verificationCode': code}),
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

  static Future<Map<String, dynamic>> recoverPassword(String newPass, String confirmPass) async {
    final email = await getStoredEmail();
    final response = await http.post(
      Uri.parse('$baseUrl/user/recover'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': newPass, 'confirmPassword': confirmPass}),
    );
    return _processResponse(response);
  }

  /// Correct Google Sign-In for google_sign_in ^7.0.0+ (December 2025)
  ///
  /// Major changes in v7:
  /// - No more currentUser / isSignedIn() / signInSilently()
  /// - Use authenticationEvents stream to detect sign-in state
  /// - authenticate() for explicit sign-in
  /// - Access token obtained via authorizationForScopes()
  static Future<Map<String, dynamic>> googleSignIn() async {
    try {
      // Configure with your Web Client ID (mandatory on Android without Firebase)
      await _googleSignIn.initialize(
        serverClientId: googleClientId, // ← Replace with your actual Web Client ID
      );

      // Trigger full sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled by the user');
      }

      // Request scopes for access token (email/profile are usually granted by default)
      const List<String> scopes = ['email', 'profile'];

      final GoogleSignInClientAuthorization? authorization =
          await googleUser.authorizationClient?.authorizationForScopes(scopes);

      final String? accessToken = authorization?.accessToken;

      if (accessToken == null) {
        throw Exception('Failed to obtain Google access token');
      }

      // Send to your backend
      final response = await http.post(
        Uri.parse('$baseUrl/user/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': accessToken}),
      );

      final data = _processResponse(response);

      // Save locally
      await saveUser(data['token'], googleUser.email);

      return data;
    } catch (e) {
      // Clean up on error
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

  // Storage helpers
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
    await prefs.clear();

    // Always sign out from Google (no need to check currentUser)
    try {
      await _googleSignIn.signOut(); // Clears cached account on next sign-in
    } catch (e) {
      print('Google sign-out error: $e');
    }
  }
}