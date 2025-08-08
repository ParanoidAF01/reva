import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reva/authentication/login.dart';

import 'package:reva/authentication/signup/verifyotp.dart';
import 'package:reva/services/auth_service.dart';
import 'package:reva/providers/user_provider.dart';
import '../../utils/first_login_helper.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isPasswordVisible = false;
  bool isRememberMe = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> mpinControllers = List.generate(6, (_) => TextEditingController());
  final List<TextEditingController> confirmMpinControllers = List.generate(6, (_) => TextEditingController());
  Future<void> _register() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fullName = fullNameController.text.trim();
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();
      final mpin = mpinControllers.map((c) => c.text).join();
      final confirmMpin = confirmMpinControllers.map((c) => c.text).join();
      if (fullName.isEmpty || email.isEmpty || phone.isEmpty || mpin.length != 6 || confirmMpin.length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }
      if (mpin != confirmMpin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MPINs do not match')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }
      final response = await AuthService().register(
        fullName: fullName,
        email: email,
        mobileNumber: phone,
        mpin: mpin,
      );

      // Debug: Check if access token is saved
      final accessToken = await AuthService().getToken('accessToken');
      print('DEBUG: Access token after signup: $accessToken');

      if (response['success'] == true && accessToken != null) {
        // Set hasLoggedInBefore flag
        await FirstLoginHelper.setHasLoggedIn();
        // Load user data after successful signup and notify provider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful!')),
        );
        // Extract mobile number from response
        String? registeredPhone = response['data']?['user']?['mobileNumber']?.toString();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VerifyOtp(prefillPhone: registeredPhone)));
      } else if (accessToken == null) {
        throw Exception('Signup failed: No access token received.');
      } else {
        // Prefer nested error message if present
        final String errorMsg = response['error']?['message'] ??
            response['message'] ?? 'Signup failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      String errorMsg = 'Signup failed';
      final es = e.toString();
      // Clean typical Exception: prefix from thrown messages
      if (es.startsWith('Exception: ')) {
        errorMsg = es.substring('Exception: '.length);
      } else if (es.isNotEmpty) {
        errorMsg = es;
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
// ...existing code continues...

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
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
                        SizedBox(height: height * 0.05),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFB0B0B0)),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.help_outline, size: 18),
                              label: const Text('Help', style: TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.01),
                        Center(
                          child: Text(
                            "Signup",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 32,
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color.fromARGB(255, 26, 32, 36), width: 1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Full Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: fullNameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Full Name',
                                  hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                                  filled: true,
                                  fillColor: const Color(0xFF2C2F36),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                              const Text('Email address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: emailController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Email address',
                                  hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                                  filled: true,
                                  fillColor: const Color(0xFF2C2F36),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text('Phone Number', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: phoneController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: 'Phone Number',
                                  hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                                  filled: true,
                                  fillColor: const Color(0xFF2C2F36),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Enter MPIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  IconButton(
                                    icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                                    onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                                  ),
                                ],
                              ),
                              _MpinBoxField(
                                controllers: mpinControllers,
                                obscureText: !isPasswordVisible,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Confirm MPIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  IconButton(
                                    icon: Icon(isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                                    onPressed: () => setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible),
                                  ),
                                ],
                              ),
                              _MpinBoxField(
                                controllers: confirmMpinControllers,
                                obscureText: !isConfirmPasswordVisible,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.065,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0262AB),
                                    Color(0xFF01345A)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        'Signup',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.04),
                        const Spacer(),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account! ",
                                style: TextStyle(color: Color(0xFFD8D8DD)),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Color(0xFF3B9FED),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Image.asset('assets/logo.png', height: 32),
                          ),
                        ),
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

// MPIN input widget for 6 boxes
class _MpinBoxField extends StatelessWidget {
  final List<TextEditingController> controllers;
  final bool obscureText;
  const _MpinBoxField({required this.controllers, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 40,
          child: TextField(
            controller: controllers[i],
            obscureText: obscureText,
            maxLength: 1,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: const Color(0xFF2C2F36),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (val) {
              if (val.length == 1 && i < 5) {
                FocusScope.of(context).nextFocus();
              } else if (val.isEmpty && i > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
          ),
        );
      }),
    );
  }
}
