import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/signup/orginisationdetailscreen.dart';
import '../components/mytextfield.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final fullNameController = TextEditingController();
  final dobController = TextEditingController();
  final designationController = TextEditingController();

  String selectedLocation = 'New Delhi';
  String selectedExperience = '2 years';

  final List<String> locations = ['New Delhi', 'Mumbai', 'Bangalore', 'Chennai'];
  final List<String> experiences = ['Less than 1 year', '1 year', '2 years', '3+ years'];

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
                    "Complete your profile",
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
                      "0%   ",
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
                      value: 0.0,
                      minHeight: 6,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0262AB)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  label: "Full Name (As per PAN / Aadhaar)",
                  hint: "User name",
                  controller: fullNameController,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: "Date of Birth",
                  hint: "09/09/2003",
                  controller: dobController,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: "Designation",
                  hint: "CEO",
                  controller: designationController,
                ),
                const SizedBox(height: 16),

                const Text(
                  "Location",
                  style: TextStyle(
                    color: Color(0xFFDFDFDF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _customBottomSheetTile(
                  title: selectedLocation,
                  onTap: () => _showBottomSheet(
                    context,
                    title: "Select Location",
                    options: locations,
                    onSelected: (val) {
                      setState(() => selectedLocation = val);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Real Estate Experience",
                  style: TextStyle(
                    color: Color(0xFFDFDFDF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _customBottomSheetTile(
                  title: selectedExperience,
                  onTap: () => _showBottomSheet(
                    context,
                    title: "Select Experience",
                    options: experiences,
                    onSelected: (val) {
                      setState(() => selectedExperience = val);
                    },
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrganisationDetailsScreen(),
                        ),
                      );
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

  Widget _customBottomSheetTile({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2F3237),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(
      BuildContext context, {
        required String title,
        required List<String> options,
        required Function(String) onSelected,
      }) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF2F3237),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              ...options.map((e) => ListTile(
                title: Text(e, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  onSelected(e);
                },
              )),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
