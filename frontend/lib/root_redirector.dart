import 'package:flutter/material.dart';

import 'package:reva/authentication/welcomescreen.dart';
import 'package:reva/bottomnavigation/bottomnavigation.dart';
import 'package:reva/services/auth_service.dart';

class RootRedirector extends StatefulWidget {
  const RootRedirector({Key? key}) : super(key: key);

  @override
  State<RootRedirector> createState() => _RootRedirectorState();
}

class _RootRedirectorState extends State<RootRedirector> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _startSplashAndCheck();
  }

  void _startSplashAndCheck() async {
    await Future.delayed(const Duration(seconds: 2));
    final auth = AuthService();
    final token = await auth.getToken('accessToken');
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BottomNavigation()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple splash screen
    return const Scaffold(
      backgroundColor: Color(0xFF22252A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 80),
            SizedBox(height: 24),
            Text('REVA', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
