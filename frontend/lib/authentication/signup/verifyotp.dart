import 'package:reva/authentication/signup/CompleteProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/services/auth_service.dart';

class VerifyOtp extends StatefulWidget {
  final String? prefillPhone;
  const VerifyOtp({super.key, this.prefillPhone});

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  late TextEditingController phoneController;
  final TextEditingController otpController = TextEditingController();
  bool otpSent = false;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController(text: widget.prefillPhone ?? '');
  }

  Future<void> _sendOtp() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final res = await AuthService().sendOtp(phoneController.text);
      if (res['success'] == true) {
        setState(() {
          otpSent = true;
          isLoading = false;
        });
      } else if (res['error'] != null && res['error']['message'] != null) {
        setState(() {
          error = res['error']['message'] ?? 'An error occurred.';
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error!),
            backgroundColor: Colors.red,
          ),
        );
      } else if (res['message'] != null) {
        setState(() {
        error = res['message'] ?? 'An error occurred.';
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error!),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
        error = res['message'] ?? 'Failed to send OTP';
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    final userOtp = otpController.text;
    if (!otpSent) {
      setState(() {
        error = 'Please request OTP first.';
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final response = await AuthService().verifyOtp(
        mobileNumber: phoneController.text,
        otp: userOtp,
      );
      final isValid = response['success'] == true;
      if (isValid) {
        setState(() {
          isLoading = false;
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const CompleteProfileScreen(),
          ),
          (route) => false,
        );
      } else {
        String? errMsg;
        if (response['error'] != null && response['error']['message'] != null) {
          errMsg = response['error']['message'];
        } else if (response['message'] != null) {
          errMsg = response['message'];
        } else {
          errMsg = 'Invalid OTP. Please try again.';
        }
        setState(() {
          error = errMsg;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        error = 'An error occurred. Please try again.';
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    Widget mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Your Mobile Number',
          style: TextStyle(
            color: Color(0xFFD8D8DD),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF23262B),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: phoneController,
            enabled: false,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              prefixText: '+91  ',
              prefixStyle: TextStyle(color: Color(0xFF6F6F6F)),
              hintText: 'Phone Number',
              hintStyle: TextStyle(color: Color(0xFF6F6F6F)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        if (error != null && !otpSent) ...[
          const SizedBox(height: 8),
          Text(
            error!,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ],
        if (!otpSent) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0262AB),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Get OTP',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16 , color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
        ] else ...[
          const SizedBox(height: 24),
          const Text('Enter OTP',
              style: TextStyle(
                  color: Color(0xFFD8D8DD), fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF23262B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFF3B9FED), width: 1.5),
            ),
            child: TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'Enter OTP',
                hintStyle: TextStyle(color: Color(0xFF6F6F6F)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                counterText: '',
              ),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 8),
          textAlign: TextAlign.center,
            ),
          ),
          if (error != null && otpSent) ...[
            const SizedBox(height: 8),
            Text(
              error!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: isLoading ? null : _sendOtp,
                child: const Text('Resend OTP',
                    style: TextStyle(
                        color: Color(0xFF3B9FED),
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0262AB),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Verify and Continue',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ],
    );
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              SizedBox(height: height * 0.06),
              Center(
                child: Text(
                  'Verify OTP',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * 0.04),
              mainContent,
              SizedBox(height: height * 0.08),
              Center(
                child: Image.asset('assets/logo.png', height: 32),
              ),
              SizedBox(height: height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
