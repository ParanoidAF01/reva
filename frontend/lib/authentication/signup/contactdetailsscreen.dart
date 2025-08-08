
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reva/providers/user_provider.dart';
import 'package:reva/authentication/signup/preferencesScreen.dart';
import 'package:reva/services/api_service.dart';
import '../components/mytextfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reva/authentication/login.dart';

class ContactDetailsScreen extends StatefulWidget {
  final bool showBack;
  const ContactDetailsScreen({Key? key, this.showBack = false}) : super(key: key);

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  TextEditingController primaryMobileNumber = TextEditingController();
  TextEditingController primaryEmailId = TextEditingController();
  TextEditingController websitePortfolio = TextEditingController();
  TextEditingController socialMediaLinks = TextEditingController();
  TextEditingController alternateMobileNumbers = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrefilledData();
    primaryMobileNumber.addListener(_saveFormData);
    primaryEmailId.addListener(_saveFormData);
    websitePortfolio.addListener(_saveFormData);
    socialMediaLinks.addListener(_saveFormData);
    alternateMobileNumbers.addListener(_saveFormData);
  }

  Future<void> _loadPrefilledData() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString('signup_primaryMobileNumber');
    final email = prefs.getString('signup_primaryEmailId');
    final website = prefs.getString('signup_websitePortfolio');
    final social = prefs.getString('signup_socialMediaLinks');
    final alternate = prefs.getString('signup_alternateMobileNumbers');

    if (mobile != null && mobile.isNotEmpty) {
      primaryMobileNumber.text = mobile;
    } else {
      final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
      if ((userData['user']?['mobileNumber'] ?? userData['mobileNumber'] ?? '').toString().isNotEmpty) {
        primaryMobileNumber.text = userData['user']?['mobileNumber'] ?? userData['mobileNumber'];
      }
    }
    if (email != null && email.isNotEmpty) {
      primaryEmailId.text = email;
    } else {
      final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
      if ((userData['user']?['email'] ?? userData['email'] ?? '').toString().isNotEmpty) {
        primaryEmailId.text = userData['user']?['email'] ?? userData['email'];
      }
    }
    if (alternate != null && alternate.isNotEmpty) {
      alternateMobileNumbers.text = alternate;
    } else {
      final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
      if ((userData['alternateNumber'] ?? '').toString().isNotEmpty) {
        alternateMobileNumbers.text = userData['alternateNumber'];
      }
    }
    if (website != null && website.isNotEmpty) {
      websitePortfolio.text = website;
    } else {
      final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
      if (userData['socialMediaLinks'] != null && userData['socialMediaLinks'] is Map) {
        final links = userData['socialMediaLinks'];
        if ((links['website'] ?? '').toString().isNotEmpty) {
          websitePortfolio.text = links['website'];
        }
      }
    }
    if (social != null && social.isNotEmpty) {
      socialMediaLinks.text = social;
    } else {
      final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
      if (userData['socialMediaLinks'] != null && userData['socialMediaLinks'] is Map) {
        final links = userData['socialMediaLinks'];
        if ((links['instagram'] ?? '').toString().isNotEmpty) {
          socialMediaLinks.text = links['instagram'];
        }
      }
    }
    setState(() {});
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('signup_primaryMobileNumber', primaryMobileNumber.text);
    await prefs.setString('signup_primaryEmailId', primaryEmailId.text);
    await prefs.setString('signup_websitePortfolio', websitePortfolio.text);
    await prefs.setString('signup_socialMediaLinks', socialMediaLinks.text);
    await prefs.setString('signup_alternateMobileNumbers', alternateMobileNumbers.text);
  }

  // Validation helpers
  bool _isValidMobile(String mobile) => RegExp(r'^[0-9]{10}$').hasMatch(mobile.trim());

  Future<void> _validateAndProceed() async {
    final mobile = primaryMobileNumber.text;
    String? error;
    if (!_isValidMobile(mobile)) {
      error = "Please enter a valid 10-digit mobile number.";
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }
    // Save to provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUserData({
      'alternateNumber': alternateMobileNumbers.text,
      'socialMediaLinks': {
        'website': websitePortfolio.text,
        'instagram': socialMediaLinks.text,
        // Add other social fields as needed
      },
    });
    // Save to shared_preferences for persistence
    await _saveFormData();
    // Send to backend with correct structure
    try {
      final response = await ApiService().put('/profiles/', {
        'alternateNumber': alternateMobileNumbers.text,
        'socialMediaLinks': {
          'website': websitePortfolio.text,
          'instagram': socialMediaLinks.text,
          // Add other social fields as needed
        },
      });
      if (response['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PreferencesScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update contact details'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error'), backgroundColor: Colors.red),
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: SingleChildScrollView(
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
                      value: 0.6,
                      minHeight: 6,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0262AB)),
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
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F3237),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB0B0B0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _validateAndProceed,
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
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Skip button removed
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
