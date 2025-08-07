import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reva/services/api_service.dart';
import 'package:reva/providers/user_provider.dart';
import 'package:reva/authentication/components/mytextfield.dart';
import '../profile/profile_percentage.dart';

class EditSpecializationAndRecognition extends StatefulWidget {
  const EditSpecializationAndRecognition({Key? key}) : super(key: key);

  @override
  State<EditSpecializationAndRecognition> createState() => _EditSpecializationAndRecognitionState();
}

class _EditSpecializationAndRecognitionState extends State<EditSpecializationAndRecognition> {
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

  Future<void> _saveSpecialization() async {
    final specialization = {
      'reraRegistered': reraRegestration,
      'reraNumber': reraNUmber.text,
      'networkingMembers': networkingMember.text.split(','),
      'realEstateWebsite': realEstateWebsite.text,
      'associatedBuilders': associatedBuilders.text.split(','),
    };
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUserData({
      'specialization': specialization
    });
    try {
      final response = await ApiService().put('/profiles/', {
        'specialization': specialization,
      });
      if (response['success'] == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProfilePercentageScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update specialization'), backgroundColor: Colors.red),
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
        title: const Text('Edit Specialization & Recognition', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.04),
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
                    onPressed: _saveSpecialization,
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
