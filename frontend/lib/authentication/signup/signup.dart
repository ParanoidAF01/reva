import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/login.dart';
import 'package:reva/authentication/signup/CompleteProfileScreen.dart';

import '../components/mytextfield.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isPasswordVisible = false;
  bool isRememberMe = false;
  bool isConfirmPasswordVisible=false;
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mpinController = TextEditingController();
  TextEditingController confirmmpinController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFF22252A),
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
                        Center(child: Text("Signup",style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 36,

                        ),),),
                        SizedBox(height: height * 0.03),
                        CustomTextField(
                          label: 'First Name',
                          hint: 'First Name',
                          controller: firstNameController,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Last Name',
                          hint: 'Last Name',
                          controller: lastNameController,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Mobile Number',
                          hint: 'Mobile Number',
                          controller: mobileNumberController,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'MPIN',
                          hint: 'MPIN',
                          controller: mpinController,
                          isPassword: true,
                          obscureText: !isPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        SizedBox(height:12,),
                        CustomTextField(
                          label: 'Confirm MPIN',
                          hint: 'Confirm MPIN',
                          controller: confirmmpinController,
                          isPassword: true,
                          obscureText: !isConfirmPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              isConfirmPasswordVisible = !isConfirmPasswordVisible;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        SizedBox(height: height * 0.04),
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.065,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> CompleteProfileScreen()));
                            },
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
                              child: Center(
                                child: Text(
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

                        Spacer(),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account! ",
                                style: TextStyle(color: Color(0xFFD8D8DD)
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>  LoginScreen()));
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

