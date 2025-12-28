import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onSignupSuccess;
  final VoidCallback onNavigateToLogin;

  const SignupScreen({
    super.key,
    required this.onSignupSuccess,
    required this.onNavigateToLogin,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  bool _isVerifying = false;
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _stopTimer();
    _animationController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
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
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _stopTimer() => _timer?.cancel();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleSignup() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar("Please fill in all fields.");
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match.");
      return;
    }

    List<String> nameParts = fullName.split(' ');
    String fname = nameParts[0];
    String lname = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : "";

    setState(() => _isLoading = true);
    try {
      await AuthService.register({
        "fname": fname,
        "lname": lname,
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
      });

      _showSnackBar("Registration successful! Please verify your email.");
      setState(() => _isVerifying = true);
      _startTimer();
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.isEmpty) {
      _showSnackBar("Please enter the OTP.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.verifyOtp(_otpController.text.trim());
      _showSnackBar("Account verified successfully!");
      _stopTimer();
      widget.onSignupSuccess();
    } catch (e) {
      _showSnackBar("Invalid OTP. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend) return;
    setState(() => _isLoading = true);
    try {
      await AuthService.resendOtp();
      _showSnackBar("A new code has been sent to your email.");
      _startTimer();
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _isVerifying ? _buildVerificationUI() : _buildSignupUI(),
        ),
      ),
    );
  }

  Widget _buildSignupUI() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cartTextColor = isDarkMode ? Colors.white : Colors.black87;

    return Column(
      children: [
        _buildLogoSection(cartTextColor),
        const SizedBox(height: 40),
        _buildGoogleButton(),
        const SizedBox(height: 20),
        _buildDivider(),
        const SizedBox(height: 20),
        _buildTextField(_fullNameController, 'Full Name', Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextField(
          _emailController,
          'Email',
          Icons.email_outlined,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildPasswordField(_passwordController, 'Password'),
        const SizedBox(height: 16),
        _buildPasswordField(
          _confirmPasswordController,
          'Confirm Password',
          isConfirm: true,
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton('Sign Up', _handleSignup),
        const SizedBox(height: 20),
        _buildNavigationLink(
          'Already have an account? Login',
          widget.onNavigateToLogin,
        ),
      ],
    );
  }

  Widget _buildVerificationUI() {
    return Column(
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 24),
        Text(
          "Verify Your Email",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter the 6-digit code sent to ${_emailController.text}",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        _buildTextField(
          _otpController,
          '6-Digit OTP',
          Icons.lock_clock_outlined,
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
                    onTap: _handleResendOtp,
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

        const SizedBox(height: 32),
        _buildPrimaryButton('Verify & Complete', _handleVerifyOtp),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _isVerifying = false),
          child: const Text("Go Back to Signup"),
        ),
      ],
    );
  }

  Widget _buildLogoSection(Color cartTextColor) {
    return Column(
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset(
            'assets/logo/logo_only.png',
            height: 60,
            width: 60,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.person_add_alt_1_rounded,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Cyber',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              'Cart',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cartTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Create your profile to start shopping',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 10,
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label, {
    bool isConfirm = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          isConfirm ? Icons.lock_reset_outlined : Icons.lock_outline,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 10,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : () {},
        icon: const FaIcon(
          FontAwesomeIcons.google,
          size: 20,
          color: Colors.red,
        ),
        label: const Text(
          'Continue with Google',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4285F4),
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Colors.grey, width: 1),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'OR',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Divider(thickness: 1)),
      ],
    );
  }

  Widget _buildNavigationLink(String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }
}
