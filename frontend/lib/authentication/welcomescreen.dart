import 'package:flutter/material.dart';
import 'package:reva/authentication/login.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final pages = [
      // Page 1: Welcome
      Column(
        children: [
          SizedBox(height: height * 0.06),
          Center(
            child: Image.asset(
              'assets/logo.png',
              height: height * 0.08,
            ),
          ),
          Text(
            'Welcome to REVA',
            style: TextStyle(
              fontSize: width * 0.070,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: height * 0.012),
          Text(
            'Real Estate Verified Agents',
            style: TextStyle(
              fontSize: width * 0.030,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFDFDFDF),
            ),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/welcome.png',
                height: height * 0.36,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: Text(
              'India’s trusted platform for agent\nnetworking, verified leads, and offline events.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width * 0.030,
                color: const Color(0xFFDFDFDF),
              ),
            ),
          ),
          SizedBox(height: height * 0.04),
        ],
      ),
      // Page 2: Onboarding
      Column(
        children: [
          SizedBox(height: height * 0.08),
          const Text(
            '🔒 Verified. Connected. \nEmpowered.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDFDFDF),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.82,
                child: Image.asset(
                  'assets/verify.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const Spacer(),
          const Center(
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BulletPoint(text: 'Connect only with RERA-verified agents'),
                  SizedBox(height: 12),
                  _BulletPoint(text: 'Share & find buyer/seller/investor leads'),
                  SizedBox(height: 12),
                  _BulletPoint(text: 'Attend exclusive builder & peer events'),
                ],
              ),
            ),
          ),
          SizedBox(height: height * 0.02),
        ],
      ),
      // Page 3: Login Navigation
      Column(
        children: [
          SizedBox(height: height * 0.08),
          const Text(
            '📈 Take Your Real Estate\nGame to the Next Level',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDFDFDF),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.82,
                child: Image.asset(
                  'assets/pg3.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: Text(
              'Build genuine connections, grow your business,\nand manage everything in one place.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width * 0.030,
                color: const Color(0xFFDFDFDF),
              ),
            ),
          ),
          SizedBox(height: height * 0.02),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: pages,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index ? const Color(0xFF0262AB) : const Color(0xFFB0B0B0),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: SizedBox(
                width: double.infinity,
                height: height * 0.065,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0262AB), Color(0xFF01345A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.08),
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFFDFDFDF),
            height: 1.5,
          ),
        ),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFFDFDFDF),
            ),
          ),
        ),
      ],
    );
  }
}
