import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:reva/authentication/signup/contactdetailsscreen.dart';
import 'package:reva/providers/user_provider.dart';
import 'package:reva/services/api_service.dart';
import 'package:reva/services/aadhaar_service.dart';

import 'package:reva/authentication/login.dart';

// Top-level controller for Aadhaar input (shared by input and button)
final TextEditingController aadharController = TextEditingController();
final TextEditingController otpController = TextEditingController();

class EKycScreen extends StatefulWidget {
  final bool showBack;
  const EKycScreen({Key? key, this.showBack = false}) : super(key: key);

  @override
  State<EKycScreen> createState() => _EKycScreenState();
}

class _EKycScreenState extends State<EKycScreen> {
  String? _requestId;
  bool _isLoading = false;
  bool _otpSent = false;
  bool _aadhaarLocked = false;
  int _resendSeconds = 0;
  Timer? _resendTimer;
  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 45;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _resendSeconds--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers if needed
  }

  void _skipToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // Prefill Aadhaar if present
    final userData = Provider.of<UserProvider>(context).userData ?? {};
    if ((userData['aadhaarNumber'] ?? '').toString().isNotEmpty && aadharController.text.isEmpty) {
      aadharController.text = userData['aadhaarNumber'];
    }

    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ...existing code for progress bar...
                Row(
                  children: [
                    Text(
                      "40%",
                      style: GoogleFonts.dmSans(color: const Color(0xFFD8D8DD), fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Of your profile is complete',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 120,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Complete your profile to 100% for getting free Reva kit + Reva business NFC card !',
                        style: GoogleFonts.dmSans(
                          color: Color(0xFFFFC107),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04),
                // Aadhaar Card Number
                const Text(
                  'Aadhaar Card Number',
                  style: TextStyle(
                    color: Color(0xFFD8D8DD),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: height * 0.01),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF23262B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: aadharController,
                          keyboardType: TextInputType.number,
                          enabled: !_aadhaarLocked,
                          decoration: InputDecoration(
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: Icon(Icons.credit_card, color: Color(0xFFFFC107)),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            hintText: '0000 0000 0000',
                            hintStyle: const TextStyle(color: Color(0xFF6F6F6F)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    if (_aadhaarLocked || _otpSent)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF0262AB)),
                        onPressed: () {
                          setState(() {
                            _aadhaarLocked = false;
                            _otpSent = false;
                            _requestId = null;
                            otpController.clear();
                          });
                        },
                      ),
                  ],
                ),
                SizedBox(height: height * 0.03),
                if (!_otpSent) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final aadhar = aadharController.text.trim();
                        if (aadhar.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter Aadhaar number'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        setState(() {
                          _isLoading = true;
                          _aadhaarLocked = true;
                        });
                        try {
                          final aadhaarService = AadhaarService();
                          final response = await aadhaarService.generateOtp(aadhar);
                          print('Aadhaar OTP Response: $response');
                          if (response['success'] == true) {
                            setState(() {
                              _requestId = response['data']?['request_id']?.toString();
                              _otpSent = true;
                            });
                            _startResendTimer();
                            print('Request ID: $_requestId');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('OTP sent successfully'), backgroundColor: Colors.green),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response['message'] ?? 'Failed to send OTP'), backgroundColor: Colors.red),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0262AB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Get OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ] else ...[
                  // OTP Section styled like verifyotp.dart
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
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _resendSeconds > 0
                          ? Text(
                              'Resend OTP in $_resendSeconds s',
                              style: const TextStyle(color: Color(0xFF6F6F6F), fontWeight: FontWeight.w600, fontSize: 12),
                            )
                          : GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () async {
                                      final aadhar = aadharController.text.trim();
                                      if (aadhar.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please enter Aadhaar number'), backgroundColor: Colors.red),
                                        );
                                        return;
                                      }
                                      setState(() => _isLoading = true);
                                      try {
                                        final aadhaarService = AadhaarService();
                                        final response = await aadhaarService.generateOtp(aadhar);
                                        if (response['success'] == true) {
                                          setState(() {
                                            _requestId = response['data']?['request_id']?.toString();
                                          });
                                          _startResendTimer();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('OTP resent successfully'), backgroundColor: Colors.green),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(response['message'] ?? 'Failed to resend OTP'), backgroundColor: Colors.red),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                        );
                                      } finally {
                                        setState(() => _isLoading = false);
                                      }
                                    },
                              child: const Text('Resend OTP', style: TextStyle(color: Color(0xFF3B9FED), fontWeight: FontWeight.w600, fontSize: 12)),
                            ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final aadhar = aadharController.text.trim();
                              final otp = otpController.text.trim();
                              if (aadhar.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter Aadhaar number'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              if (otp.isEmpty || otp.length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter OTP'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              if (_requestId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please generate OTP first'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              setState(() => _isLoading = true);
                              try {
                                final aadhaarService = AadhaarService();
                                final response = await aadhaarService.submitOtp(_requestId!, otp);
                                print('Submit OTP Response: $response');
                                if (response['success'] == true && response['data']?['status'] == 'success') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ContactDetailsScreen()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(response['message'] ?? 'OTP verification failed'), backgroundColor: Colors.red),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                );
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0262AB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Verify and Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
