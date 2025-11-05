import 'dart:async';
import 'package:cybercart/theme/app_theme.dart';
import 'package:cybercart/utils/nav_bar.dart';
import 'package:cybercart/utils/onboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const CyberCart());
  });
}

class CyberCart extends StatelessWidget {
  const CyberCart({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainAppWrapper(),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startHideTimer();
      _loadOnboardingState();
    });
  }

  void _loadOnboardingState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool hasSeenOnboarding = prefs.getBool(_onboardedKey) ?? false;

    if (mounted) {
      setState(() {
        _showOnboarding = !hasSeenOnboarding;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;

    if (!isKeyboardVisible) {
      _hideSystemNavigation();
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

  void _showSystemNavigation() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _onUserInteraction() {
    _showSystemNavigation();
    _startHideTimer();
  }

  void _onOnboardingComplete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_onboardedKey, true);

    if (mounted) {
      setState(() {
        _showOnboarding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
}
