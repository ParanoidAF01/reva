import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/signup/signup.dart';
import 'package:reva/services/auth_service.dart';
import 'package:reva/authentication/signup/newmpin.dart';

class OtpScreen extends StatefulWidget {
  final String? prefillPhone;
  const OtpScreen({super.key, this.prefillPhone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late TextEditingController phoneController;
  final TextEditingController otpController = TextEditingController();
  bool otpSent = false;
  bool isLoading = false;
  String? error;
  bool isEditingPhone = false;

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
        otpSent = true;
      } else if (res['error'] != null && res['error']['message'] != null) {
        error = res['error']['message'];
      } else if (res['message'] != null) {
        error = res['message'];
      } else {
        error = 'Failed to send OTP';
      }
    } catch (e) {
      error = e.toString();
    }
    setState(() {
      isLoading = false;
    });
    if (error != null) {
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
      error = 'Please request OTP first.';
      setState(() {
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
    final response = await AuthService().verifyOtp(
      mobileNumber: phoneController.text,
      otp: userOtp,
    );
    final isValid = response['success'] == true;
    setState(() {
      isLoading = false;
    });
    if (isValid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewMPIN(mobileNumber: phoneController.text),
        ),
      );
    } else {
      setState(() {
        error = 'Invalid OTP. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    Widget mainContent;
    if (!otpSent) {
      mainContent = Column(
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0262AB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Get OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? ", style: TextStyle(color: Color(0xFF6F6F6F))),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignUp()),
                  );
                },
                child: const Text('Signup', style: TextStyle(color: Color(0xFF3B9FED), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      );
    } else if (isEditingPhone) {
      mainContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Enter Your Mobile Number',
                style: TextStyle(
                  color: Color(0xFFD8D8DD),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF23262B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: phoneController,
              enabled: true,
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0262AB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Get OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      );
    } else {
      mainContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Enter Your Mobile Number',
                style: TextStyle(
                  color: Color(0xFFD8D8DD),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF3B9FED), size: 20),
                tooltip: 'Edit phone number',
                onPressed: isLoading
                    ? null
                    : () {
                        setState(() {
                          isEditingPhone = true;
                          otpSent = false;
                          otpController.clear();
                        });
                      },
              ),
            ],
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
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF6F6F6F)),
          const SizedBox(height: 16),
          const Text('Enter OTP', style: TextStyle(color: Color(0xFFD8D8DD), fontWeight: FontWeight.w500)),
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
                  letterSpacing: 32,
                  fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: isLoading ? null : _sendOtp,
                child: const Text('Resend OTP', style: TextStyle(color: Color(0xFF3B9FED), fontWeight: FontWeight.w600, fontSize: 12)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Verify and Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: height * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6F6F6F)),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.help_outline, size: 18),
                    label: const Text('Help'),
                  ),
                ],
              ),
              SizedBox(height: height * 0.01),
              Center(
                child: Text(
                  'Forgot MPIN',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * 0.04),
              mainContent,
              const Spacer(),
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
