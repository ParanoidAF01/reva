import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/signup/preferencesScreen.dart';

import '../components/mytextfield.dart';

class ContactDetailsScreen extends StatefulWidget {
  const ContactDetailsScreen({super.key});

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  TextEditingController primaryMobileNumber = TextEditingController();
  TextEditingController primaryEmailId = TextEditingController();
  TextEditingController websitePortfolio= TextEditingController();
  TextEditingController socialMediaLinks= TextEditingController();
  TextEditingController alternateMobileNumbers= TextEditingController();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.07),
                const Center(
                  child: Text(
                    "Contact Details",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      "60%   ",
                      style: GoogleFonts.dmSans(
                        color: Color(0xFFD8D8DD),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Completed..",
                      style: GoogleFonts.dmSans(
                        color: Color(0xFF6F6F6F),
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: width * 0.6,
                    child: LinearProgressIndicator(
                      value: 0.6,
                      minHeight: 6,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0262AB)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  label: "Primary Mobile Number",
                  hint: "00000 00000",
                  controller: primaryMobileNumber,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: "Primary EmailId",
                  hint: "xyz@gmail.com",
                  controller: primaryEmailId,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: "Website / Portfolio",
                  hint: "www.xyz.com",
                  controller: websitePortfolio,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Social Media Links",
                  hint: "instagram",
                  controller: socialMediaLinks,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Alternate Mobile Number",
                  hint: "00000 00000",
                  controller: alternateMobileNumbers,
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=> PreferencesScreen()) );
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
                      child: const Center(
                        child: Text(
                          'Next',
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
