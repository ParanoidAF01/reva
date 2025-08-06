import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:reva/authentication/signup/signup.dart';
import 'package:reva/authentication/signup/otpscreen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:reva/services/auth_service.dart';
import 'package:reva/bottomnavigation/bottomnavigation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:reva/start_subscription.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:reva/providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Social login handlers
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        // TODO: Send googleUser info to backend for auth
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in successful!')),
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const BottomNavigation()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
    }
  }

  Future<void> _handleAppleSignIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ],
      );
      // TODO: Send credential info to backend for auth
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apple sign-in successful!')),
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const BottomNavigation()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apple sign-in failed: $e')),
      );
    }
  }

  Future<void> _handleFacebookSignIn() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        // TODO: Send result.accessToken to backend for auth
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Facebook sign-in successful!')),
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const BottomNavigation()));
      } else {
        throw result.message ?? 'Unknown error';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Facebook sign-in failed: $e')),
      );
    }
  }

  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> mpinControllers =
      List.generate(6, (_) => TextEditingController());
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _setPhoneNumber();
  }

  Future<void> _setPhoneNumber() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String phone = androidInfo.id.substring(0, 10);
      setState(() {
        phoneController.text = phone;
      });
    } catch (e) {
      setState(() {
        phoneController.text = '';
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });
    try {
      final phone = phoneController.text.trim();
      final mpin = mpinControllers.map((c) => c.text).join();
      if (phone.isEmpty || mpin.length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please enter your phone number and 6-digit MPIN')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response =
          await AuthService().login(mobileNumber: phone, mpin: mpin);

      if (response['success'] == true) {
        // Load user data after successful login
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUserData();
        await userProvider.checkSubscription();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
        // Redirect based on subscription status
        if (userProvider.isSubscribed == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavigation()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StartSubscriptionPage()),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      String errorMsg = 'Login failed';
      if (e.toString().contains('not found')) {
        errorMsg = 'User not found. Please check your phone number.';
      } else if (e.toString().contains('invalid')) {
        errorMsg = 'Invalid MPIN. Please try again.';
      } else if (e.toString().contains('network')) {
        errorMsg = 'Network error. Please try again.';
      } else if (e.toString().isNotEmpty) {
        errorMsg = e.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF181B20),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.04),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Color(0xFFB2C2D9)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 2),
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.help_outline,
                                  size: 18, color: Color(0xFFB2C2D9)),
                              label: const Text('Help',
                                  style: TextStyle(
                                      color: Color(0xFFB2C2D9),
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Center(
                            child: Text('Login',
                                style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 32,
                                    color: Colors.white))),
                        const SizedBox(height: 32),
                        const Text('Phone Number',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: phoneController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Phone Number',
                            hintStyle:
                                const TextStyle(color: Color(0xFFB0B0B0)),
                            filled: true,
                            fillColor: const Color(0xFF23262B),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text('Enter Your MPIN',
                            style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.white)),
                        const SizedBox(height: 12),
                        _MpinBoxField(
                          controllers: mpinControllers,
                          onChanged: (index, value) {
                            if (value.isNotEmpty && index < 5) {
                              FocusScope.of(context).nextFocus();
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OtpScreen(),
                                  ),
                                );
                              },
                              child: Text('Forgot MPIN?',
                                  style: GoogleFonts.dmSans(
                                      color: const Color(0xFFB2C2D9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0262AB),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text('Login',
                                    style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don’t have an account? ",
                                  style: GoogleFonts.dmSans(
                                      color: const Color(0xFFD8D8DD),
                                      fontSize: 15)),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignUp()));
                                },
                                child: Text("Signup",
                                    style: GoogleFonts.dmSans(
                                        color: const Color(0xFF3B9FED),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: Opacity(
                            opacity: 0.18,
                            child: Image.asset('assets/logo.png', height: 32),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Widget for 6 MPIN boxes
class _MpinBoxField extends StatelessWidget {
  final List<TextEditingController> controllers;
  final void Function(int, String) onChanged;
  const _MpinBoxField({required this.controllers, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(6, (i) {
        return Container(
          width: width * 0.11,
          height: width * 0.11,
          margin: EdgeInsets.only(right: i < 5 ? width * 0.025 : 0),
          decoration: BoxDecoration(
            color: const Color(0xFF23262B),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: controllers[i],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: GoogleFonts.dmSans(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (val) => onChanged(i, val),
          ),
        );
      }),
    );
  }
}

// Social login button widget
