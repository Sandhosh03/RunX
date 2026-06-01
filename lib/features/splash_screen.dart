import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/onboarding_service.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'onboarding/onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'settings/personal_info_screen.dart';
import '../features/navigation/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> supabaseInit;
  const SplashScreen({super.key, required this.supabaseInit});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Run initialization logic concurrently with animation delay
    final results = await Future.wait([
      Future.delayed(const Duration(milliseconds: 1500)),
      widget.supabaseInit,
      OnboardingService.shouldShowOnboarding(),
      AuthService.isLoggedIn(),
    ]);

    if (!mounted) return;

    final showOnboarding = results[2] as bool;
    final isLoggedIn = results[3] as bool;

    Widget nextScreen;
    if (!isLoggedIn) {
      // ALWAYS require login first
      nextScreen = const LoginScreen();
    } else if (showOnboarding) {
      // If logged in but first time on this device/session
      nextScreen = const OnboardingScreen();
    } else {
      // Check if profile is complete
      final profile = await ProfileService.getProfile();
      if (profile == null || !profile.isComplete) {
        nextScreen = const PersonalInfoScreen();
      } else {
        nextScreen = const MainNavigation();
      }
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/branding/splash_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'RunX',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'BEYOND LIMITS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white38,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
