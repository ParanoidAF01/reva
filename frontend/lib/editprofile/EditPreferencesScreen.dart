import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reva/services/api_service.dart';
import 'package:reva/providers/user_provider.dart';
import '../profile/profile_percentage.dart';

class EditPreferencesScreen extends StatefulWidget {
  const EditPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<EditPreferencesScreen> createState() => _EditPreferencesScreenState();
}

class _EditPreferencesScreenState extends State<EditPreferencesScreen> {
  List<String> operatingLoactions = [
    "India",
    "International"
  ];
  List<String> propertyTypes = [
    "Residential",
    "Commercial",
    "Industrial",
    "Agricultural",
    "Other"
  ];
  List<String> networkingPreferences = [
    "Business",
    "Technology",
    "Health",
    "Education",
    "Entertainment",
    "Sports",
    "Other"
  ];
  List<String> targetClients = [
    "Business",
    "Technology",
    "Health",
    "Education",
    "Entertainment",
    "Sports",
    "Other"
  ];
  List<String> interests = [
    "Business",
    "Technology",
    "Health",
    "Education",
    "Entertainment",
    "Sports",
    "Other"
  ];

  String operatingLocation = "India";
  String interest = "Business";
  String propertyType = "Residential";
  String networkingPreference = "Business";
  String targetClient = "Business";

  @override
  void initState() {
    super.initState();
    final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
    if ((userData['operatingLocation'] ?? '').toString().isNotEmpty && operatingLoactions.contains(userData['operatingLocation'])) {
      operatingLocation = userData['operatingLocation'];
    }
    if ((userData['interest'] ?? '').toString().isNotEmpty && interests.contains(userData['interest'])) {
      interest = userData['interest'];
    }
    if ((userData['propertyType'] ?? '').toString().isNotEmpty && propertyTypes.contains(userData['propertyType'])) {
      propertyType = userData['propertyType'];
    }
    if ((userData['networkingPreference'] ?? '').toString().isNotEmpty && networkingPreferences.contains(userData['networkingPreference'])) {
      networkingPreference = userData['networkingPreference'];
    }
    if ((userData['targetClient'] ?? '').toString().isNotEmpty && targetClients.contains(userData['targetClient'])) {
      targetClient = userData['targetClient'];
    }
  }

  Future<void> _savePreferences() async {
    final preferences = {
      'operatingLocations': operatingLocation,
      'interests': [
        interest
      ],
      'propertyType': propertyType,
      'networkingPreferences': networkingPreference,
      'targetClients': targetClient,
    };
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUserData({
      'preferences': preferences
    });
    try {
      final response = await ApiService().put('/profiles/', {
        'preferences': preferences,
      });
      if (response['success'] == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProfilePercentageScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update preferences'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildBottomSheetField({
    required String label,
    required String value,
    required List<String> options,
    required void Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFDFDFDF),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: const Color(0xFF2F3237),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (_) => ListView(
                shrinkWrap: true,
                children: options.map((option) {
                  return ListTile(
                    title: Text(option, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(option);
                    },
                  );
                }).toList(),
              ),
            );
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2F3237),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(color: Colors.grey)),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
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
        title: const Text('Edit Preferences', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.04),
                _buildBottomSheetField(
                    label: "Operating Location",
                    value: operatingLocation,
                    options: operatingLoactions,
                    onSelected: (val) {
                      setState(() => operatingLocation = val);
                    }),
                _buildBottomSheetField(
                    label: "Interest",
                    value: interest,
                    options: interests,
                    onSelected: (val) {
                      setState(() => interest = val);
                    }),
                const SizedBox(height: 16),
                _buildBottomSheetField(
                    label: "Property Type",
                    value: propertyType,
                    options: propertyTypes,
                    onSelected: (val) {
                      setState(() => propertyType = val);
                    }),
                const SizedBox(height: 16),
                _buildBottomSheetField(
                    label: "Networking Preferences",
                    value: networkingPreference,
                    options: networkingPreferences,
                    onSelected: (val) {
                      setState(() => networkingPreference = val);
                    }),
                const SizedBox(height: 16),
                _buildBottomSheetField(
                    label: "Target Client",
                    value: targetClient,
                    options: targetClients,
                    onSelected: (val) {
                      setState(() => targetClient = val);
                    }),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _savePreferences,
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
