import 'dart:async';
import 'package:cybercart/theme/app_theme.dart';
import 'package:cybercart/utils/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// class _HomeScreenState extends State<HomeScreen> {
//   Timer? _hideTimer;

//   @override
//   void initState() {
//     super.initState();
//     _startHideTimer();
//   }

//   void _startHideTimer() {
//     _hideTimer?.cancel();
//     _hideTimer = Timer(const Duration(seconds: 2), () {
//       _hideSystemNavigation();
//     });
//   }

//   void _hideSystemNavigation() {
//     SystemChrome.setEnabledSystemUIMode(
//       SystemUiMode.manual,
//       overlays: [SystemUiOverlay.top],
//     );
//   }

//   void _showSystemNavigation() {
//     SystemChrome.setEnabledSystemUIMode(
//       SystemUiMode.manual,
//       overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
//     );
//   }

//   void _onUserInteraction() {
//     _showSystemNavigation();
//     _startHideTimer();
//   }

//   @override
//   void dispose() {
//     _hideTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness platformBrightness = MediaQuery.of(
//       context,
//     ).platformBrightness;
//     final Brightness iconBrightness = platformBrightness == Brightness.dark
//         ? Brightness.light
//         : Brightness.dark;

//     final Color primaryColor = Theme.of(context).primaryColor;
//     // SystemUiOverlayStyle(
//     //   statusBarColor: primaryColor,
//     //   statusBarIconBrightness: iconBrightness,
//     //   systemNavigationBarIconBrightness: iconBrightness,
//     // );

//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onTap: _onUserInteraction,
//       onPanDown: (_) => _onUserInteraction(),
//       child: Scaffold(
//         // appBar: AppBar(
//         //   centerTitle: true,
//         //   backgroundColor: primaryColor,
//         //   systemOverlayStyle: SystemUiOverlayStyle(
//         //     statusBarColor: primaryColor,
//         //     statusBarIconBrightness: iconBrightness,
//         //     systemNavigationBarIconBrightness: iconBrightness,
//         //   ),
//         //   title: const Text("CyberCart"),
//         // ),
//         // body: Center(
//         //   child: Text(
//         //     'Welcome to CyberCart',
//         //     style: Theme.of(context).textTheme.headlineMedium,
//         //   ),
//         // ),
//         bottomNavigationBar: const CustomNavigationBar(),
//       ),
//     );
//   }
// }

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startHideTimer();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    super.dispose();
  }

  // Detect when the keyboard opens or closes
  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;

    if (!isKeyboardVisible) {
      // Keyboard just closed → re-enter immersive mode
      _hideSystemNavigation();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), _hideSystemNavigation);
  }

  void _hideSystemNavigation() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  }

  void _showSystemNavigation() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _onUserInteraction() {
    _showSystemNavigation();
    _startHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _onUserInteraction,
      onPanDown: (_) => _onUserInteraction(),
      child: Scaffold(
        bottomNavigationBar: const CustomNavigationBar(),
      ),
    );
  }
}
