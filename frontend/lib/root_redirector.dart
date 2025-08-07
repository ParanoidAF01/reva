import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:reva/authentication/welcomescreen.dart';
import 'package:reva/services/auth_service.dart';
import 'authentication/mpin_verification_screen.dart';

class RootRedirector extends StatefulWidget {
  const RootRedirector({super.key});

  @override
  State<RootRedirector> createState() => _RootRedirectorState();
}

class _RootRedirectorState extends State<RootRedirector> {
  final bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _startSplashAndCheck();
  }

  void _startSplashAndCheck() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final auth = AuthService();
    final token = await auth.getToken('accessToken');
    final userId = await auth.getToken('userId');
    final userEmail = await auth.getToken('userEmail');
    final userMobile = await auth.getToken('userMobileNumber');
    final userFullName = await auth.getToken('userFullName');

    // Check if all required user data and token exist
    final hasUserData = userId != null && userId.isNotEmpty &&
        userEmail != null && userEmail.isNotEmpty &&
        userMobile != null && userMobile.isNotEmpty &&
        userFullName != null && userFullName.isNotEmpty;

    if (token != null && token.isNotEmpty && hasUserData) {
      // Token and user data exist, go to MPIN screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MpinVerificationScreen()),
      );
    } else {
      // Token or user data missing, go to WelcomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Splash screen with Lottie animation
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://cdn.lottielab.com/l/88RomMJcwji6xU.json',
              width: 500,
              height: 500,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 24),
            const Text('REVA',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
