import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:reva/authentication/welcomescreen.dart';
import 'package:reva/bottomnavigation/bottomnavigation.dart';
import 'package:reva/services/auth_service.dart';
import 'package:reva/providers/user_provider.dart';
import 'package:reva/start_subscription.dart';

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

    if (token != null && token.isNotEmpty) {
      // User is logged in, check subscription
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserData();
      await userProvider.checkSubscription();

      if (!mounted) return;

      // Debug print to verify value
      debugPrint('RootRedirector: isSubscribed = ${userProvider.isSubscribed}');

      if (userProvider.isSubscribed == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BottomNavigation()),
        );
      } else {
        // User is logged in but not subscribed
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StartSubscriptionPage()),
        );
      }
    } else {
      // User is not logged in
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
