import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _token;
  String? _userId;
  String? _email;
  String? _name;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get userId => _userId;
  String? get email => _email;
  String? get name => _name;

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> loginSuccess(
    String token,
    String userId,
    String email,
    String fname,
    String lname,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await AuthService.saveUser(token, email);

    await prefs.setString('userId', userId);
    await prefs.setString('fname', fname);
    await prefs.setString('lname', lname);

    _isAuthenticated = true;
    _token = token;
    _userId = userId;
    _email = email;
    _name = '$fname $lname';
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final data = await AuthService.getStoredUser();

    if (data['token'] != null && data['email'] != null) {
      _isAuthenticated = true;
      _token = data['token'];
      _userId = prefs.getString('userId');
      _email = data['email'];

      String fname = prefs.getString('fname') ?? "";
      String lname = prefs.getString('lname') ?? "";
      _name = '$fname $lname'.trim();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await AuthService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fname');
    await prefs.remove('lname');
    _isAuthenticated = false;
    _token = null;
    _userId = null;
    _email = null;
    _name = null;
    notifyListeners();
    Navigator.pushReplacementNamed(context, '/signin');
  }
}
