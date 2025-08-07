import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reva/authentication/login.dart';
import 'package:reva/providers/user_provider.dart';
import 'package:reva/services/api_service.dart';

import '../components/mytextfield.dart';

class SpecializationAndRecognition extends StatefulWidget {
  final bool showBack;
  const SpecializationAndRecognition({Key? key, this.showBack = false}) : super(key: key);

  @override
  State<SpecializationAndRecognition> createState() => _SpecializationAndRecognitionState();
}

class _SpecializationAndRecognitionState extends State<SpecializationAndRecognition> {
  bool reraRegestration = false;

  TextEditingController reraNUmber = TextEditingController();
  TextEditingController networkingMember = TextEditingController();
  TextEditingController realEstateWebsite = TextEditingController();
  TextEditingController associatedBuilders = TextEditingController();
  @override
  void initState() {
    super.initState();
    final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
    if ((userData['reraNumber'] ?? '').toString().isNotEmpty) {
      reraNUmber.text = userData['reraNumber'];
    }
    if ((userData['networkingMember'] ?? '').toString().isNotEmpty) {
      networkingMember.text = userData['networkingMember'];
    }
    if ((userData['realEstateWebsite'] ?? '').toString().isNotEmpty) {
      realEstateWebsite.text = userData['realEstateWebsite'];
    }
    if ((userData['associatedBuilders'] ?? '').toString().isNotEmpty) {
      associatedBuilders.text = userData['associatedBuilders'];
    }
  }

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
                    "Specialisation & Recognition",
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
                      "100%   ",
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFFD8D8DD),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
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
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: width * 0.6,
                    child: const LinearProgressIndicator(
                      value: 1,
                      minHeight: 6,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0262AB)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'RERA Regestration',
                  style: TextStyle(
                    color: Color(0xFFDFDFDF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F3237),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'yes or no',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Switch(
                        value: reraRegestration,
                        onChanged: (val) {
                          setState(() => reraRegestration = val);
                        },
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "RERA NUMBER",
                  hint: "0000 0000 00",
                  controller: reraNUmber,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Networking Member (Optional)",
                  hint: "ibrddg,bere,enhs",
                  controller: networkingMember,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Real Estate Websites (Optional)",
                  hint: "waofsavbf",
                  controller: realEstateWebsite,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Associated Builders (Optional)",
                  hint: "esgopesg,gsgeg,drhhr",
                  controller: associatedBuilders,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      _validateAndProceed();
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
                          colors: [
                            Color(0xFF0262AB),
                            Color(0xFF01345A)
                          ],
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

  Future<void> _validateAndProceed() async {
    // Build specialization object
    final specialization = {
      'reraRegistered': reraRegestration,
      'reraNumber': reraNUmber.text,
      'networkingMembers': networkingMember.text.split(','),
      'realEstateWebsite': realEstateWebsite.text,
      'associatedBuilders': associatedBuilders.text.split(','),
    };
    // Save to provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUserData({
      'specialization': specialization
    });
    // Send to backend with correct structure
    try {
      final response = await ApiService().put('/profiles/', {
        'specialization': specialization,
      });
      if (response['success'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to update specialization');
      }
    } catch (e) {
      _showErrorSnackBar(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFB00020),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
