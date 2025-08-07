import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reva/services/api_service.dart';
import 'package:reva/providers/user_provider.dart';
import 'package:reva/authentication/components/mytextfield.dart';
import '../profile/profile_percentage.dart';

class EditContactDetailsScreen extends StatefulWidget {
  const EditContactDetailsScreen({Key? key}) : super(key: key);

  @override
  State<EditContactDetailsScreen> createState() => _EditContactDetailsScreenState();
}

class _EditContactDetailsScreenState extends State<EditContactDetailsScreen> {
  TextEditingController primaryMobileNumber = TextEditingController();
  TextEditingController primaryEmailId = TextEditingController();
  TextEditingController websitePortfolio = TextEditingController();
  TextEditingController socialMediaLinks = TextEditingController();
  TextEditingController alternateMobileNumbers = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
    if ((userData['user']?['mobileNumber'] ?? userData['mobileNumber'] ?? '').toString().isNotEmpty) {
      primaryMobileNumber.text = userData['user']?['mobileNumber'] ?? userData['mobileNumber'];
    }
    if ((userData['user']?['email'] ?? userData['email'] ?? '').toString().isNotEmpty) {
      primaryEmailId.text = userData['user']?['email'] ?? userData['email'];
    }
    if ((userData['alternateNumber'] ?? '').toString().isNotEmpty) {
      alternateMobileNumbers.text = userData['alternateNumber'];
    }
    if (userData['socialMediaLinks'] != null && userData['socialMediaLinks'] is Map) {
      final links = userData['socialMediaLinks'];
      if ((links['website'] ?? '').toString().isNotEmpty) {
        websitePortfolio.text = links['website'];
      }
      if ((links['instagram'] ?? '').toString().isNotEmpty) {
        socialMediaLinks.text = links['instagram'];
      }
    }
  }

  bool _isValidMobile(String mobile) => RegExp(r'^[0-9]{10}$').hasMatch(mobile.trim());

  Future<void> _saveContactDetails() async {
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUserData({
      'alternateNumber': alternateMobileNumbers.text,
      'socialMediaLinks': {
        'website': websitePortfolio.text,
        'instagram': socialMediaLinks.text,
      },
    });
    try {
      final response = await ApiService().put('/profiles/', {
        'alternateNumber': alternateMobileNumbers.text,
        'socialMediaLinks': {
          'website': websitePortfolio.text,
          'instagram': socialMediaLinks.text,
        },
      });
      if (response['success'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfilePercentageScreen()),
          (route) => false,
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF22252A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Edit Contact Details', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.04),
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
                    onPressed: _saveContactDetails,
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
                          'Save',
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
