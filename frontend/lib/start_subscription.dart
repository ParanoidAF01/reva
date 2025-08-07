import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:reva/authentication/welcomescreen.dart';
import 'package:reva/services/auth_service.dart';
import 'package:reva/services/subscription_service.dart';
import 'package:reva/bottomnavigation/bottomnavigation.dart';
import 'utils/navigation_helper.dart';

class StartSubscriptionPage extends StatefulWidget {
  const StartSubscriptionPage({super.key});

  @override
  State<StartSubscriptionPage> createState() => _StartSubscriptionPageState();
}

class _StartSubscriptionPageState extends State<StartSubscriptionPage> {
  int _selected = 0; // 0: Annual, 1: Monthly
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22252A),
        elevation: 0,
        leading: Container(),
        actions: [
          FutureBuilder<bool>(
            future: AuthService().isLoggedIn(),
            builder: (context, snapshot) {
              final isLoggedIn = snapshot.data ?? false;
              return IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Sign Out',
                onPressed: isLoggedIn
                    ? () async {
                        try {
                          await AuthService.performCompleteLogout();
                        } catch (e) {
                          debugPrint('Logout error: $e');
                        }
                        NavigationHelper.navigateToWelcomeScreen();
                      }
                    : null,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height * 0.06),
            // Top images grid
            SizedBox(
              height: height * 0.13,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...[
                    'assets/interior.png',
                    'assets/eventdummyimage.png',
                    'assets/homebuyer.png',
                    'assets/material.png',
                    'assets/bronze_background.png',
                    'assets/goldCard.png',
                    'assets/silver_background.png',
                  ].map((img) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(img,
                              height: height * 0.12,
                              width: width * 0.22,
                              fit: BoxFit.cover),
                        ),
                      ))
                ],
              ),
            ),
            SizedBox(height: height * 0.04),
            Text(
              'Power Up Your REVA Experience',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Stay verified, visible, and\nconnected — without limits.',
              style: GoogleFonts.dmSans(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: height * 0.03),
            // Annual & Monthly options
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _selected = 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selected == 0
                            ? const Color(0xFF0262AB)
                            : const Color(0xFF22252A),
                        border: Border.all(color: Colors.white, width: 1.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Annual',
                                    style: GoogleFonts.dmSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17)),
                                const SizedBox(height: 20),
                                Text('First 7 days free - Then ₹899/Year',
                                    style: GoogleFonts.dmSans(
                                        color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Best Value',
                                style: GoogleFonts.dmSans(
                                    color: const Color(0xFF0262AB),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => setState(() => _selected = 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selected == 1
                            ? const Color(0xFF0262AB)
                            : const Color(0xFF22252A),
                        border: Border.all(color: Colors.white, width: 1.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Monthly',
                                    style: GoogleFonts.dmSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17)),
                                const SizedBox(height: 20),
                                Text('First 7 days free - Then ₹99/Month',
                                    style: GoogleFonts.dmSans(
                                        color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.03),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _featureText('Verified Profile & Badge'),
                  _featureText('Unlimited Connections'),
                  _featureText('Ad-free Experience'),
                  _featureText('Premium Event Access'),
                ],
              ),
            ),
            SizedBox(height: height * 0.02),
            Text(
              'Enjoy Premium access at only ₹3/day',
              style: GoogleFonts.dmSans(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: height * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0262AB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Start 7-day free trial',
                    style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Text.rich(
                TextSpan(
                  text: 'By placing this order, you agree to the ',
                  style:
                      GoogleFonts.dmSans(color: Colors.white70, fontSize: 13),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: GoogleFonts.dmSans(
                          color: const Color(0xFF0262AB),
                          fontSize: 13,
                          decoration: TextDecoration.underline),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy.',
                      style: GoogleFonts.dmSans(
                          color: const Color(0xFF0262AB),
                          fontSize: 13,
                          decoration: TextDecoration.underline),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _featureText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Text(text,
              style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 15)),
        ],
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Create subscription request body
      final subscriptionData = {
        "plan": _selected == 0 ? "annual" : "monthly",
        "amountPaid": _selected == 0 ? 899 : 99,
        "paymentMethod": "card"
      };

      // Send subscription request to API
      final subscriptionService = SubscriptionService();
      await subscriptionService.createSubscription(subscriptionData);

      // Navigate to home screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BottomNavigation()),
        (route) => false,
      );
    } catch (e) {
      // If API call fails, still navigate to home but show error
      debugPrint('Subscription API error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Payment successful but subscription update failed. Please contact support."),
          backgroundColor: Colors.orange,
        ),
      );

      // Navigate to home screen anyway
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BottomNavigation()),
        (route) => false,
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Payment Failed! Please try again."),
      backgroundColor: Colors.red,
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("External Wallet Selected: ${response.walletName}"),
      backgroundColor: Colors.blue,
    ));
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_QyOoTjd4T2z2Nj',
      'amount': _selected == 0 ? 89900 : 9900,
      'name': 'REVA',
      'description':
          _selected == 0 ? 'Annual Subscription' : 'Monthly Subscription',
      'prefill': {'contact': '9123456789', 'email': 'testuser@example.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
