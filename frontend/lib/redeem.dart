import 'package:flutter/material.dart';
import 'package:reva/home/components/goldCard.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:reva/services/nfc_card_service.dart';

class RedeemPage extends StatefulWidget {
  const RedeemPage({super.key});

  @override
  State<RedeemPage> createState() => _RedeemPageState();
}

class _RedeemPageState extends State<RedeemPage> with SingleTickerProviderStateMixin {
  bool _showGoldCard = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool achievementUnlocked = false; // Set to false to test locked state
  late Razorpay _razorpay;
  final NfcCardService _nfcCardService = NfcCardService();
  Future<void> _claimNfcCard() async {
    // You can collect user info here if needed
    final requestData = {
      "note": "Requesting NFC card"
    };
    try {
      final response = await _nfcCardService.requestNfcCard(requestData);
      if (response["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("NFC Card requested successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Failed to request NFC Card.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showGoldCard) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _showGoldCard = !_showGoldCard;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFF5B8DCB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height * 0.04),
            // Top celebration icon
            Center(
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Image.asset('assets/celebrate.png', height: 32, width: 32),
              ),
            ),
            SizedBox(height: height * 0.02),
            // NFC Card Unlocked
            Center(
              child: Container(
                width: width * 0.88,
                decoration: BoxDecoration(
                  color: const Color(0xFF22252A),
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Want NFC Card?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF232E1B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Congratulations!', style: TextStyle(color: Color(0xFF7ED957), fontWeight: FontWeight.w500, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('UNLOCKED', style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0262AB),
                            Color(0xFF5B8DCB)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      child: const Text(
                        'You will receive your card at the provided address.',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: height * 0.04),
            // Achievement Card (Locked/Unlocked)
            Center(
              child: Container(
                width: width * 0.88,
                decoration: BoxDecoration(
                  color: const Color(0xFF22252A),
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
                child: achievementUnlocked
                    ? GestureDetector(
                        onTap: _flipCard,
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            final isFront = _animation.value < 0.5;
                            final angle = _animation.value * 3.1416;
                            if (isFront) {
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(angle),
                                child: Column(
                                  children: [
                                    const Text('Achievement Unlocked!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                                    SizedBox(height: height * 0.02),
                                    CircleAvatar(
                                      radius: 38,
                                      backgroundColor: const Color(0xFF22252A),
                                      child: Image.asset('assets/giftbox.png', height: 54, width: 54),
                                    ),
                                    SizedBox(height: height * 0.01),
                                    const Text('Tap the box to reveal', style: TextStyle(color: Colors.white70, fontSize: 15)),
                                  ],
                                ),
                              );
                            } else {
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(angle + 3.1416),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.white,
                                          child: Image.asset('assets/celebrate.png', height: 26, width: 26),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text('Congratulations!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                                      ],
                                    ),
                                    SizedBox(height: height * 0.02),
                                    const GoldCard(
                                      name: "Ayush Kumar.",
                                      location: "Delhi NCR",
                                      experience: "4+ years",
                                      languages: "Hindi, English",
                                      tag1: "Commercial",
                                      tag2: "Plots",
                                      tag3: "Rental",
                                      kycStatus: "KYC Approved",
                                    ),
                                    SizedBox(height: height * 0.01),
                                    const Text('Golden league unlocked', style: TextStyle(color: Colors.white70, fontSize: 15)),
                                    SizedBox(height: height * 0.02),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _claimNfcCard,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0262AB),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 0,
                                        ),
                                        child: const Text('Redeem Now!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      )
                    : Column(
                        children: [
                          const Text('Achievement Locked', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                          SizedBox(height: height * 0.02),
                          const CircleAvatar(
                            radius: 38,
                            backgroundColor: Color(0xFF22252A),
                            child: Icon(Icons.lock, color: Colors.white54, size: 38),
                          ),
                          SizedBox(height: height * 0.01),
                          const Text('Unlock this card for ₹5000', style: TextStyle(color: Colors.white70, fontSize: 15)),
                          SizedBox(height: height * 0.02),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _openCheckout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0262AB),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text('Pay Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: height * 0.09),
          ],
        ),
      ),
      //bottomNavigationBar: const BottomNavigation(),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Payment Successful! Card Unlocked."),
      backgroundColor: Colors.green,
    ));
    setState(() {
      achievementUnlocked = true;
    });
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
      'amount': 500000, // ₹5000 in paise
      'name': 'REVA',
      'description': 'Unlock Achievement Card',
      'prefill': {
        'contact': '9123456789',
        'email': 'testuser@example.com'
      },
      'external': {
        'wallets': [
          'paytm'
        ]
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Payment initialization failed: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
