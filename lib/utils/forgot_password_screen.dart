import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;

  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void dispose() {
    _stopTimer();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _stopTimer();
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
          _stopTimer();
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _showSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );

  Future<void> _sendCode() async {
    if (_emailController.text.isEmpty) return _showSnackBar("Enter your email");
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _emailController.text.trim());
      await AuthService.resendOtp();
      _showSnackBar("Verification code sent to email.");
      setState(() => _currentStep = 1);
      _startTimer();
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;
    setState(() => _isLoading = true);
    try {
      await AuthService.resendOtp();
      _showSnackBar("A new code has been sent.");
      _startTimer();
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_otpController.text.isEmpty) return _showSnackBar("Enter the OTP code");
    setState(() => _isLoading = true);
    try {
      await AuthService.verifyOtp(_otpController.text);
      _stopTimer();
      setState(() => _currentStep = 2);
    } catch (e) {
      _showSnackBar("Invalid Code");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text.isEmpty)
      return _showSnackBar("Enter new password");
    if (_newPasswordController.text != _confirmPasswordController.text) {
      return _showSnackBar("Passwords do not match");
    }
    setState(() => _isLoading = true);
    try {
      await AuthService.recoverPassword(
        _newPasswordController.text,
        _confirmPasswordController.text,
      );
      _showSnackBar("Password changed successfully!");
      Navigator.pushReplacementNamed(context, '/signin');
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: _buildStepUI(),
            ),
    );
  }

  Widget _buildStepUI() {
    String title = "";
    String subtitle = "";
    List<Widget> fields = [];
    VoidCallback onNext = () {};
    String buttonText = "";

    if (_currentStep == 0) {
      title = "Forgot Password?";
      subtitle = "Enter your registered email to receive a verification code.";
      fields = [
        _buildUIField(
          controller: _emailController,
          label: "Email Address",
          hint: "example@mail.com",
          icon: Icons.email_outlined,
          type: TextInputType.emailAddress,
        ),
      ];
      onNext = _sendCode;
      buttonText = "SEND CODE";
    } else if (_currentStep == 1) {
      title = "Verify OTP";
      subtitle =
          "Please enter the 6-digit code sent to ${_emailController.text}.";
      fields = [
        _buildUIField(
          controller: _otpController,
          label: "OTP Code",
          hint: "123456",
          icon: Icons.lock_clock_outlined,
          type: TextInputType.number,
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _canResend ? "Didn't receive a code? " : "Resend code in ",
              style: const TextStyle(color: Colors.grey),
            ),
            _canResend
                ? GestureDetector(
                    onTap: _resendCode,
                    child: Text(
                      "Resend",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Text(
                    "00:${_secondsRemaining.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ],
        ),
      ];
      onNext = _verifyCode;
      buttonText = "VERIFY CODE";
    } else {
      title = "New Password";
      subtitle = "Create a strong password to secure your account.";
      fields = [
        _buildUIField(
          controller: _newPasswordController,
          label: "New Password",
          hint: "••••••••",
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 16),
        _buildUIField(
          controller: _confirmPasswordController,
          label: "Confirm Password",
          hint: "••••••••",
          icon: Icons.lock_reset_outlined,
          isPassword: true,
        ),
      ];
      onNext = _resetPassword;
      buttonText = "CHANGE PASSWORD";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _currentStep == 2
                  ? Icons.verified_user_outlined
                  : Icons.lock_reset,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 32),
        ...fields,
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (_currentStep > 0)
          Center(
            child: TextButton(
              onPressed: () {
                _stopTimer();
                setState(() => _currentStep--);
              },
              child: const Text("Go Back"),
            ),
          ),
      ],
    );
  }

  Widget _buildUIField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
