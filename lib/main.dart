import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/landing_screen.dart';
import 'features/samples/presentation/sample_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init notice: $e');
  }

  final authController = AuthController();
  await authController.init();

  runApp(RevolPortalApp(authController: authController));
}

enum AppRouteState {
  landing,
  login,
  sampleList,
}

class RevolPortalApp extends StatefulWidget {
  final AuthController authController;

  const RevolPortalApp({super.key, required this.authController});

  @override
  State<RevolPortalApp> createState() => _RevolPortalAppState();
}

class _RevolPortalAppState extends State<RevolPortalApp> {
  late AppRouteState _currentRoute;

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.authController.isAuthenticated
        ? AppRouteState.sampleList
        : AppRouteState.landing;
    widget.authController.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    widget.authController.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {
        if (widget.authController.isAuthenticated) {
          _currentRoute = AppRouteState.sampleList;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revol LIMS Client Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentRoute) {
      case AppRouteState.landing:
        return LandingScreen(
          authController: widget.authController,
          onLoginSuccess: () {
            setState(() => _currentRoute = AppRouteState.sampleList);
          },
          onNavigateToLogin: () {
            setState(() => _currentRoute = AppRouteState.login);
          },
        );

      case AppRouteState.login:
        return LoginScreen(
          authController: widget.authController,
          onLoginSuccess: () {
            setState(() => _currentRoute = AppRouteState.sampleList);
          },
        );

      case AppRouteState.sampleList:
        return SampleListScreen(
          authController: widget.authController,
          onLogout: () async {
            await widget.authController.logout();
            setState(() => _currentRoute = AppRouteState.landing);
          },
        );
    }
  }
}
