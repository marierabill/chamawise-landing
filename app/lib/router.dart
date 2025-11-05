import 'package:flutter/material.dart';

// 🔹 Auth Screens
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/onboarding_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';

// 🔹 Main App Screens
import 'features/home/presentation/home_screen.dart';
import 'features/user/presentation/profile_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildRoute(const SplashScreen());
      case '/onboarding':
        return _buildRoute(const OnboardingScreen());
      case '/login':
        return _buildRoute(const LoginScreen());
      case '/register':
        return _buildRoute(const RegisterScreen());
      case '/home':
        return _buildRoute(const HomeScreen());
      case '/profile':
        return _buildRoute(const ProfileScreen());

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text(
                'No route defined for ${settings.name}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
    }
  }

  // 🔹 Helper for cleaner route creation
  static MaterialPageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }
}
