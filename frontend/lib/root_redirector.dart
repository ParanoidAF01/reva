import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:reva/authentication/welcomescreen.dart';
import 'package:reva/bottomnavigation/bottomnavigation.dart';
import 'package:reva/services/auth_service.dart';
import 'package:reva/providers/user_provider.dart';
import 'package:reva/start_subscription.dart';
import 'utils/first_login_helper.dart';
import 'authentication/login.dart';
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
    final hasLoggedInBefore = await FirstLoginHelper.hasLoggedInBefore();

    if (token == null || token.isEmpty) {
      // No token, show login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // Token exists, check user and subscription
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserData();
    if (!mounted) return;
    if (userProvider.userData == null) {
      // User data failed to load (token invalid)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    await userProvider.checkSubscription();
    if (!mounted) return;

    // If not subscribed, always show subscription page
    if (userProvider.isSubscribed != true) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StartSubscriptionPage()),
      );
      return;
    }

    // Subscribed: decide which screen to show
    // If first open after signup (hasLoggedInBefore == false), show login
    if (!hasLoggedInBefore) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // If second or later open, show MPIN screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MpinVerificationScreen()),
    );
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
