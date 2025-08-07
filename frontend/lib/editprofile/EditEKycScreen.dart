import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reva/services/api_service.dart';
import 'package:reva/providers/user_provider.dart';
import '../profile/profile_percentage.dart';

class EditEKycScreen extends StatefulWidget {
  const EditEKycScreen({Key? key}) : super(key: key);

  @override
  State<EditEKycScreen> createState() => _EditEKycScreenState();
}

class _EditEKycScreenState extends State<EditEKycScreen> {
  final TextEditingController aadharController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
    if ((userData['aadhaarNumber'] ?? '').toString().isNotEmpty && aadharController.text.isEmpty) {
      aadharController.text = userData['aadhaarNumber'];
    }
  }

  Future<void> _saveEKYC() async {
    final aadhar = aadharController.text.trim();
    if (aadhar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Aadhaar number'), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      final response = await ApiService().put('/profiles/', {
        'maskedAadharNumber': aadhar,
        'kycVerified': true,
      });
      if (response['success'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfilePercentageScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update KYC'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error'), backgroundColor: Colors.red),
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
        title: const Text('Edit E-KYC', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.07),
              const Text(
                'Adhar Card Number',
                style: TextStyle(
                  color: Color(0xFFD8D8DD),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: height * 0.01),
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
              SizedBox(height: height * 0.04),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveEKYC,
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
    );
  }
}
