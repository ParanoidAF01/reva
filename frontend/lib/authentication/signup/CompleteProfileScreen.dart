import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/signup/orginisationdetailscreen.dart';
import '../components/mytextfield.dart';
import 'package:provider/provider.dart';
import 'package:reva/providers/user_provider.dart';
import 'package:reva/services/api_service.dart';
import 'package:reva/authentication/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompleteProfileScreen extends StatefulWidget {
  final bool showBack;
  const CompleteProfileScreen({Key? key, this.showBack = false})
    : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  void _skipToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  final fullNameController = TextEditingController();
  final dobController = TextEditingController();
  static const List<String> DESIGNATIONS = [
    "Builder",
    "Loan Provider",
    "Interior Designer",
    "Material Supplier",
    "Legal Advisor",
    "Vastu Consultant",
    "Home Buyer",
    "Property Investor",
    "Construction Manager",
    "Real Estate Agent",
    "Technical Consultant",
    "Other",
  ];
  String? selectedDesignation;
  String selectedLocation = 'New Delhi';
  String selectedExperience = '';

  @override
  void initState() {
    super.initState();
    _loadPrefilledData();
    // Add listeners to save data as user types
    fullNameController.addListener(_saveFormData);
    dobController.addListener(_saveFormData);
  }

  Future<void> _loadPrefilledData() async {
    final prefs = await SharedPreferences.getInstance();
    // Try to load from shared_preferences first
    final fullName = prefs.getString('signup_fullName');
    final dob = prefs.getString('signup_dob');
    final designation = prefs.getString('signup_designation');
    final location = prefs.getString('signup_location');
    final experience = prefs.getString('signup_experience');

    if (fullName != null && fullName.isNotEmpty) {
      fullNameController.text = fullName;
    } else {
      // fallback to provider
      final userData =
          Provider.of<UserProvider>(context, listen: false).userData ?? {};
      String? providerFullName =
          userData['user']?['fullName'] ?? userData['fullName'];
      if ((providerFullName ?? '').toString().isNotEmpty) {
        fullNameController.text = providerFullName!;
      }
    }
    if (dob != null && dob.isNotEmpty) {
      dobController.text = dob;
    } else {
      final userData =
          Provider.of<UserProvider>(context, listen: false).userData ?? {};
      if ((userData['dateOfBirth'] ?? '').toString().isNotEmpty) {
        final dobRaw = userData['dateOfBirth'];
        String? formattedDob;
        if (dobRaw is String && dobRaw.isNotEmpty) {
          DateTime? dt;
          try {
            dt = DateTime.tryParse(dobRaw);
          } catch (_) {}
          if (dt != null) {
            formattedDob =
                '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
          } else if (dobRaw.contains('-')) {
            final parts = dobRaw.split('-');
            if (parts.length == 3) {
              formattedDob =
                  '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
            }
          }
          formattedDob ??= dobRaw;
          dobController.text = formattedDob;
        }
      }
    }
    if (designation != null && designation.isNotEmpty) {
      setState(() {
        selectedDesignation = designation;
      });
    } else {
      final userData =
          Provider.of<UserProvider>(context, listen: false).userData ?? {};
      if ((userData['designation'] ?? '').toString().isNotEmpty) {
        setState(() {
          selectedDesignation = userData['designation'];
        });
      }
    }
    if (location != null && location.isNotEmpty) {
      setState(() {
        selectedLocation = location;
      });
    } else {
      final userData =
          Provider.of<UserProvider>(context, listen: false).userData ?? {};
      if ((userData['location'] ?? '').toString().isNotEmpty) {
        setState(() {
          selectedLocation = userData['location'];
        });
      }
    }
    if (experience != null && experience.isNotEmpty) {
      setState(() {
        selectedExperience = experience;
      });
    } else {
      final userData =
          Provider.of<UserProvider>(context, listen: false).userData ?? {};
      if (userData['experience'] != null) {
        final exp = userData['experience'];
        if (exp is int) {
          if (exp == 0)
            selectedExperience = 'Less than 1 year';
          else if (exp == 1)
            selectedExperience = '1 year';
          else if (exp == 2)
            selectedExperience = '2 years';
          else if (exp == 3)
            selectedExperience = '3+ years';
        } else if (exp is String && exp.isNotEmpty) {
          selectedExperience = exp;
        }
      }
    }
    setState(() {});
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('signup_fullName', fullNameController.text);
    await prefs.setString('signup_dob', dobController.text);
    await prefs.setString('signup_designation', selectedDesignation ?? '');
    await prefs.setString('signup_location', selectedLocation);
    await prefs.setString('signup_experience', selectedExperience);
  }

  final List<String> locations = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];
  final List<String> experienceOptions = [
    'Less than 1 year',
    '1 year',
    '2 years',
    '3+ years',
  ];

  // Validation helpers
  bool _isValidFullName(String name) => name.trim().isNotEmpty;
  // bool _isValidDesignation(String designation) => designation.trim().isNotEmpty;
  bool _isValidLocation(String location) => locations.contains(location);
  bool _isValidExperience(String exp) {
    // Accept only the defined experience options
    return experienceOptions.contains(exp);
  }

  bool _isValidDate(String date) {
    // Accepts dd/mm/yyyy or dd-mm-yyyy
    final regex = RegExp(
      r'^(0[1-9]|[12][0-9]|3[01])[\/\-](0[1-9]|1[0-2])[\/\-](19|20)\d{2}$',
    );
    return regex.hasMatch(date.trim());
  }

  Future<void> _validateAndProceed() async {
    final name = fullNameController.text;
    final dob = dobController.text;
    final designation = selectedDesignation;
    final location = selectedLocation;
    // Convert experience string to number
    int experienceNum = 0;
    if (selectedExperience == 'Less than 1 year')
      experienceNum = 0;
    else if (selectedExperience == '1 year')
      experienceNum = 1;
    else if (selectedExperience == '2 years')
      experienceNum = 2;
    else if (selectedExperience == '3+ years')
      experienceNum = 3;

    // Convert dob to ISO format (yyyy-mm-dd)
    String dobIso = '';
    try {
      final parts = dob.split('/');
      if (parts.length == 3) {
        dobIso =
            '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      }
    } catch (_) {}

    String? error;
    if (!_isValidFullName(name)) {
      error = "Please enter your full name.";
    } else if (!_isValidDate(dob)) {
      error = "Please enter a valid date of birth (dd/mm/yyyy).";
    } else if (designation == null) {
      error = "Please select your designation.";
    } else if (!_isValidLocation(location)) {
      error = "Please select a valid location.";
    } else if (!_isValidExperience(selectedExperience)) {
      error = "Please select your real estate experience.";
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    // Save to provider (optional, for local state)
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUserData({
      'fullName': name,
      'dateOfBirth': dobIso,
      'designation': designation,
      'location': location,
      'experience': experienceNum,
    });
    // Save to shared_preferences for persistence
    await _saveFormData();
    // Send to backend with correct structure
    try {
      final response = await ApiService().put('/profiles/', {
        'fullName': name,
        'dateOfBirth': dobIso,
        'designation': designation,
        'location': location,
        'experience': experienceNum,
      });
      if (response['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OrganisationDetailsScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
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
                // Skip button removed
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF0262AB),
                      ),
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
                            ),
                            dialogTheme: DialogThemeData(
                              backgroundColor: Color(0xFF23262B),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      String formatted =
                          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
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
                const Text(
                  "Select Your REVA Role Category",
                  style: TextStyle(
                    color: Color(0xFFDFDFDF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _customBottomSheetTile(
                  title: selectedDesignation ?? "Select Designation",
                  onTap: () => _showBottomSheet(
                    context,
                    title: "Select Designation",
                    options: DESIGNATIONS,
                    onSelected: (val) {
                      setState(() => selectedDesignation = val);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "State",
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
                  title: selectedExperience.isEmpty
                      ? "Select Experience"
                      : selectedExperience,
                  onTap: () => _showBottomSheet(
                    context,
                    title: "Select Experience",
                    options: experienceOptions,
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

  Widget _customBottomSheetTile({
    required String title,
    required VoidCallback onTap,
  }) {
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 12),
                ...options.map(
                  (e) => ListTile(
                    title: Text(e, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(e);
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
