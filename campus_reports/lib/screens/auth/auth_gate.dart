import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../student/home_screen.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) return const LoginScreen();
    if (!auth.isVerified) return const VerifyEmailScreen();
    return const HomeScreen();
  }
}
