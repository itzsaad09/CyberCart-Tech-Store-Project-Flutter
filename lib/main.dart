import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:cybercart/theme/app_theme.dart';
import 'package:cybercart/providers/auth_provider.dart';
import 'package:cybercart/utils/nav_bar.dart';
import 'package:cybercart/utils/onboard_screen.dart';
import 'package:cybercart/utils/login_screen.dart';
import 'package:cybercart/utils/signup_screen.dart';
import 'package:cybercart/utils/forgot_password_screen.dart';

class ThemeController extends InheritedWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) setThemeMode;

  const ThemeController({
    super.key,
    required this.themeMode,
    required this.setThemeMode,
    required Widget child,
  }) : super(child: child);

  static ThemeController of(BuildContext context) {
    final ThemeController? result = context
        .dependOnInheritedWidgetOfExactType<ThemeController>();
    assert(result != null, 'No ThemeController found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant ThemeController oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await GoogleSignIn.instance.initialize(
    serverClientId: dotenv.env['WEB_GOOGLE_CLIENT_ID']!,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
        child: const CyberCart(),
      ),
    );
  });
}

class CyberCart extends StatefulWidget {
  const CyberCart({super.key});

  @override
  State<CyberCart> createState() => _CyberCartState();
}

class _CyberCartState extends State<CyberCart> {
  ThemeMode _themeMode = ThemeMode.system;
  static const String _themeKey = 'app_theme_mode';

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (mounted) {
      setState(() {
        if (savedTheme == 'light') {
          _themeMode = ThemeMode.light;
        } else if (savedTheme == 'dark') {
          _themeMode = ThemeMode.dark;
        } else {
          _themeMode = ThemeMode.system;
        }
      });
    }
  }

  void setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
    if (mounted) {
      setState(() => _themeMode = mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeController(
      themeMode: _themeMode,
      setThemeMode: setThemeMode,
      child: MaterialApp(
        title: 'CyberCart',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,

        home: const MainAppWrapper(),

        routes: {
          '/signin': (context) => LoginScreen(
            onLoginSuccess: () => Navigator.pushReplacementNamed(context, '/'),
            onNavigateToSignup: () => Navigator.pushNamed(context, '/signup'),
          ),
          '/signup': (context) => SignupScreen(
            onSignupSuccess: () => Navigator.pushNamed(context, '/verify'),
            onNavigateToLogin: () =>
                Navigator.pushReplacementNamed(context, '/signin'),
          ),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
        },
      ),
    );
  }
}

class MainAppWrapper extends StatefulWidget {
  const MainAppWrapper({super.key});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper>
    with WidgetsBindingObserver {
  Timer? _hideTimer;
  static const String _onboardedKey = 'has_onboarded';
  bool _showOnboarding = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAppData();
  }

  Future<void> _initAppData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool(_onboardedKey) ?? false;

    if (mounted) {
      await Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
      setState(() {
        _showOnboarding = !hasSeenOnboarding;
        _isLoading = false;
      });
      _startHideTimer();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), _hideSystemNavigation);
  }

  void _hideSystemNavigation() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }

  void _showSystemNavigation() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  void _onUserInteraction() {
    _showSystemNavigation();
    _startHideTimer();
  }

  void _onOnboardingComplete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardedKey, true);
    if (mounted) setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (_isLoading || auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _onOnboardingComplete);
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _onUserInteraction,
      onPanDown: (_) => _onUserInteraction(),
      child: const CustomNavigationBar(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    super.dispose();
  }
}
