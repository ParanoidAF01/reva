import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    if ((userData['aadhaarNumber'] ?? '').toString().isNotEmpty &&
        aadharController.text.isEmpty) {
      aadharController.text = userData['aadhaarNumber'];
    }

    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.07),
              if (widget.showBack)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              Center(
                child: Text(
                  'E-KYC Verification',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * 0.04),

              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  onPressed: () => _skipToLogin(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0262AB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Color(0xFF0262AB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              /// Progress Text
              Row(
                children: [
                  Text(
                    "40%   ",
                    style: GoogleFonts.dmSans(
                        color: const Color(0xFFD8D8DD),
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "Completed..",
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFF6F6F6F),
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: width * 0.6,
                  child: const LinearProgressIndicator(
                    value: 0.4,
                    minHeight: 6,
                    backgroundColor: Colors.white,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF0262AB)),
                  ),
                ),
              ),
              SizedBox(height: height * 0.04),

              /// Aadhaar Label
              const Text(
                'Adhar Card Number',
                style: TextStyle(
                  color: Color(0xFFD8D8DD),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: height * 0.01),

              /// Aadhaar Input
              // Aadhaar input controller (moved to top for access in button)
              SizedBox(
                child: TextField(
                  controller: aadharController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '0000 0000 0000',
                    hintStyle: TextStyle(color: Color(0xFF6F6F6F)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              SizedBox(height: height * 0.02),

              /// Get OTP Button
              InkWell(
                onTap: () async {
                  final aadhar = aadharController.text.trim();
                  if (aadhar.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter Aadhaar number'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    final aadhaarService = AadhaarService();
                    final response = await aadhaarService.generateOtp(aadhar);

                    // Debug: Print the response structure
                    print('Aadhaar OTP Response: $response');

                    if (response['success'] == true) {
                      setState(() {
                        // Extract request_id from the correct location
                        _requestId =
                            response['data']?['request_id']?.toString();
                        _otpSent = true;
                      });

                      // Debug: Print the request_id
                      print('Request ID: $_requestId');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('OTP sent successfully'),
                            backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                response['message'] ?? 'Failed to send OTP'),
                            backgroundColor: Colors.red),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0262AB),
                        Color(0xFF01345A),
                      ],
                    ),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Get OTP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ),

              SizedBox(height: height * 0.03),

              /// OTP Label and Resend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enter OTP',
                    style: TextStyle(
                      color: Color(0xFFD8D8DD),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_otpSent)
                    InkWell(
                      onTap: () async {
                        final aadhar = aadharController.text.trim();
                        if (aadhar.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter Aadhaar number'),
                                backgroundColor: Colors.red),
                          );
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          final aadhaarService = AadhaarService();
                          final response =
                              await aadhaarService.generateOtp(aadhar);

                          if (response['success'] == true) {
                            setState(() {
                              _requestId =
                                  response['data']?['request_id']?.toString();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('OTP resent successfully'),
                                  backgroundColor: Colors.green),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(response['message'] ??
                                      'Failed to resend OTP'),
                                  backgroundColor: Colors.red),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red),
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      child: const Text(
                        'resend',
                        style: TextStyle(
                          color: Color(0xFF0262AB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: height * 0.015),

              /// OTP Input
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  hintText: 'Enter 6-digit OTP',
                  hintStyle: TextStyle(color: Color(0xFF6F6F6F)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  counterText: '',
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),

              SizedBox(height: height * 0.05),

              /// Verify Button
              InkWell(
                onTap: () async {
                  final aadhar = aadharController.text.trim();
                  final otp = otpController.text.trim();

                  if (aadhar.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter Aadhaar number'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }

                  if (otp.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter OTP'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }

                  // Debug: Print current state
                  print('Current Request ID: $_requestId');
                  print('OTP Sent: $_otpSent');

                  if (_requestId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please generate OTP first'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    final aadhaarService = AadhaarService();
                    final response =
                        await aadhaarService.submitOtp(_requestId!, otp);

                    // Debug: Print the submit response
                    print('Submit OTP Response: $response');

                    if (response['success'] == true &&
                        response['data']?['status'] == 'success') {
                      // Backend handles profile update, just navigate to next screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ContactDetailsScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(response['message'] ??
                                'OTP verification failed'),
                            backgroundColor: Colors.red),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: height * 0.065,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0262AB),
                        Color(0xFF01345A),
                      ],
                    ),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Verify and Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
