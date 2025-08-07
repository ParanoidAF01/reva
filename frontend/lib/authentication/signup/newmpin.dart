import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/login.dart';
import 'package:reva/authentication/signup/signup.dart';

import '../components/mytextfield.dart';

import 'package:reva/services/auth_service.dart';

class NewMPIN extends StatefulWidget {
  final String mobileNumber;
  const NewMPIN({super.key, required this.mobileNumber});

  @override
  State<NewMPIN> createState() => _NewMPINState();
}

class _NewMPINState extends State<NewMPIN> {
  bool isPasswordVisible = false;
  bool isRememberMe = false;
  bool isConfirmPasswordVisible = false;
  TextEditingController mpinController = TextEditingController();
  TextEditingController confirmmpinController = TextEditingController();

  bool isLoading = false;

  Future<void> _changeMpin() async {
    final mpin = mpinController.text.trim();
    final confirmMpin = confirmmpinController.text.trim();
    if (mpin.length != 6 || confirmMpin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MPIN must be 6 digits'), backgroundColor: Colors.red),
      );
      return;
    }
    if (mpin != confirmMpin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MPINs do not match'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => isLoading = true);
    final res = await AuthService().forgotPassword(mobileNumber: widget.mobileNumber, newMpin: mpin);
    setState(() => isLoading = false);
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MPIN changed successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Failed to change MPIN'), backgroundColor: Colors.red),
      );
    }
  }

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
                        SizedBox(height: height * 0.1),
                        Center(
                          child: Text(
                            "Forgot MPIN",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 36,
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'MPIN',
                          hint: '666 666',
                          controller: mpinController,
                          isPassword: true,
                          obscureText: !isPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        CustomTextField(
                          label: 'Confirm MPIN',
                          hint: '666 666',
                          controller: confirmmpinController,
                          isPassword: true,
                          obscureText: !isConfirmPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              isConfirmPasswordVisible = !isConfirmPasswordVisible;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(height: height * 0.04),
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.065,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _changeMpin,
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
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text(
                                        'Change MPIN',
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
                                "Don't have an account! ",
                                style: TextStyle(color: Color(0xFFD8D8DD)),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUp()));
                                },
                                child: const Text(
                                  "Sign UP",
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
