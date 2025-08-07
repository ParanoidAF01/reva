import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reva/authentication/signup/specializationandrecongination.dart';
import 'package:reva/providers/user_provider.dart';
import 'package:reva/services/api_service.dart';

class PreferencesScreen extends StatefulWidget {
  final bool showBack;
  const PreferencesScreen({Key? key, this.showBack = false}) : super(key: key);

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  List<String> targetClients = [
    "Business",
    "Technology",
    "Health",
    "Education",
    "Entertainment",
    "Sports",
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
  List<String> propertyTypes = [
    "Residential",
    "Commercial",
    "Industrial",
    "Agricultural",
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
  List<String> operatingLoactions = [
    "India",
    "International"
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
                    "Preferences",
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
                      "80%   ",
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
                      value: 0.8,
                      minHeight: 6,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0262AB)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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

  Future<void> _validateAndProceed() async {
    // Collect data
    // Build preferences object
    final preferences = {
      'operatingLocations': operatingLocation,
      'interests': [
        interest
      ],
      'propertyType': propertyType,
      'networkingPreferences': networkingPreference,
      'targetClients': targetClient,
    };
    // Save to provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUserData({
      'preferences': preferences
    });
    // Send to backend
    try {
      final response = await ApiService().put('/profiles/', {
        'preferences': preferences,
      });
      if (response['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SpecializationAndRecognition()),
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

  void _skipPreferences() {
    Navigator.pushReplacementNamed(context, '/login');
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
                const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
