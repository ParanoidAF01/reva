import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/signup/signup.dart';

import 'components/mytextfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool ismpinVisible = false;
  bool isRememberMe = false;
  TextEditingController mpinController = TextEditingController();

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
                        SizedBox(height: height * 0.15),
                        Center(child: Image.asset("assets/login.png")),
                        SizedBox(height: height * 0.03),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'MPIN',
                          hint: 'MPIN',
                          controller: mpinController,
                          isPassword: true,
                          obscureText: !ismpinVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              ismpinVisible = !ismpinVisible;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.04),
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.065,
                          child: ElevatedButton(
                            onPressed: () {},
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
                                  colors: [Color(0xFF0262AB), Color(0xFF01345A)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'Login',
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
                              "Don’t have an account? ",
                              style: TextStyle(color: Color(0xFFD8D8DD)
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>  SignUp()));
                              },
                              child: const Text(
                                "Signup",
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
