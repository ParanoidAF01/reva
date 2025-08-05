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

  // Validation helpers
  bool _isValidFullName(String name) => name.trim().isNotEmpty;
  bool _isValidDesignation(String designation) => designation.trim().isNotEmpty;
  bool _isValidLocation(String location) => locations.contains(location);
  bool _isValidExperience(String exp) => experiences.contains(exp);
  bool _isValidDate(String date) {
    // Accepts dd/mm/yyyy or dd-mm-yyyy
    final regex = RegExp(r'^(0[1-9]|[12][0-9]|3[01])[\/\-](0[1-9]|1[0-2])[\/\-](19|20)\d{2}$');
    return regex.hasMatch(date.trim());
  }

  void _validateAndProceed() {
    final name = fullNameController.text;
    final dob = dobController.text;
    final designation = designationController.text;
    final location = selectedLocation;
    final experience = selectedExperience;

    String? error;
    if (!_isValidFullName(name)) {
      error = "Please enter your full name.";
    } else if (!_isValidDate(dob)) {
      error = "Please enter a valid date of birth (dd/mm/yyyy).";
    } else if (!_isValidDesignation(designation)) {
      error = "Please enter your designation.";
    } else if (!_isValidLocation(location)) {
      error = "Please select a valid location.";
    } else if (!_isValidExperience(experience)) {
      error = "Please select your real estate experience.";
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrganisationDetailsScreen(),
      ),
    );
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
                      value: 0.0,
                      minHeight: 6,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0262AB)),
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

                GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFF0262AB),
                              onPrimary: Colors.white,
                              surface: Color(0xFF22252A),
                              onSurface: Colors.white,
                            ), dialogTheme: DialogThemeData(backgroundColor: Color(0xFF23262B)),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      String formatted = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                      setState(() {
                        dobController.text = formatted;
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: CustomTextField(
                      label: "Date of Birth",
                      hint: "09/09/2003",
                      controller: dobController,
                    ),
                  ),
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
