import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/data/home_repository.dart';
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

  // Initialize guest session on app open
  try {
    await HomeRepository().createSession();
  } catch (e) {
    debugPrint('App launch session init notice: $e');
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
    _currentRoute = widget.authController.isAuthenticated ? AppRouteState.sampleList : AppRouteState.landing;
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
        } else {
          _currentRoute = AppRouteState.landing;
        }
      });
    }
  }

  /// Global view scale factor (90% fixed view for web and mobile view)
  static const double viewScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revol LIMS Client Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        final mediaQuery = MediaQuery.of(context);
        if (mediaQuery.size.width <= 0 || mediaQuery.size.height <= 0) {
          return child;
        }

        final scaledSize = Size(
          mediaQuery.size.width / viewScale,
          mediaQuery.size.height / viewScale,
        );

        return MediaQuery(
          data: mediaQuery.copyWith(
            size: scaledSize,
            padding: mediaQuery.padding / viewScale,
            viewInsets: mediaQuery.viewInsets / viewScale,
            viewPadding: mediaQuery.viewPadding / viewScale,
          ),
          child: FittedBox(
            fit: BoxFit.fill,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: scaledSize.width,
              height: scaledSize.height,
              child: child,
            ),
          ),
        );
      },
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
          initialNavIndex: 0,
          authController: widget.authController,
          onLogout: () async {
            await widget.authController.logout();
            setState(() => _currentRoute = AppRouteState.landing);
          },
        );
    }
  }
}
