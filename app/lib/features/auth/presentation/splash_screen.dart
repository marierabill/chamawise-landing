import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_providers.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';


class SplashScreen extends ConsumerWidget {
const SplashScreen({super.key});


@override
Widget build(BuildContext context, WidgetRef ref) {
final authState = ref.watch(authStateChangesProvider);


return authState.when(
data: (user) {
if (user == null) {
return const LoginScreen();
} else {
// If just created, send to onboarding; otherwise home (we'll use onboarding for now)
return const OnboardingScreen();
}
},
loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
error: (e, st) => Scaffold(body: Center(child: Text('Error: \$e'))),
);
}
}