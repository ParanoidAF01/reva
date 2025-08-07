import 'package:flutter/material.dart';
import 'package:reva/authentication/components/mytextfield.dart';
import 'package:provider/provider.dart';
import 'package:reva/services/api_service.dart';
import 'package:reva/providers/user_provider.dart';
import '../profile/profile_percentage.dart';

class EditCompleteProfileScreen extends StatefulWidget {
  const EditCompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditCompleteProfileScreen> createState() => _EditCompleteProfileScreenState();
}

class _EditCompleteProfileScreenState extends State<EditCompleteProfileScreen> {
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
    "Other"
  ];
  String? selectedDesignation;
  String selectedLocation = 'New Delhi';
  String selectedExperience = '';

  @override
  void initState() {
    super.initState();
    final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
    String? fullName = userData['user']?['fullName'] ?? userData['fullName'];
    if ((fullName ?? '').toString().isNotEmpty) {
      fullNameController.text = fullName!;
    }
    if ((userData['dateOfBirth'] ?? '').toString().isNotEmpty) {
      final dobRaw = userData['dateOfBirth'];
      String? formattedDob;
      if (dobRaw is String && dobRaw.isNotEmpty) {
        DateTime? dt;
        try {
          dt = DateTime.tryParse(dobRaw);
        } catch (_) {}
        if (dt != null) {
          formattedDob = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
        } else if (dobRaw.contains('-')) {
          final parts = dobRaw.split('-');
          if (parts.length == 3) {
            formattedDob = '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
          }
        }
        formattedDob ??= dobRaw;
        dobController.text = formattedDob;
      }
    }
    if ((userData['designation'] ?? '').toString().isNotEmpty && DESIGNATIONS.contains(userData['designation'])) {
      selectedDesignation = userData['designation'];
    } else {
      selectedDesignation = DESIGNATIONS.first;
    }
    if ((userData['location'] ?? '').toString().isNotEmpty) {
      selectedLocation = userData['location'];
    }
    if (userData['experience'] != null) {
      final exp = userData['experience'];
      if (exp is int) {
        if (exp == 0) selectedExperience = 'Less than 1 year';
        else if (exp == 1) selectedExperience = '1 year';
        else if (exp == 2) selectedExperience = '2 years';
        else if (exp == 3) selectedExperience = '3+ years';
      } else if (exp is String && exp.isNotEmpty) {
        selectedExperience = exp;
      }
    }
  }

  final List<String> locations = [
    'New Delhi',
    'Mumbai',
    'Bangalore',
    'Chennai'
  ];
  final List<String> experienceOptions = [
    'Less than 1 year',
    '1 year',
    '2 years',
    '3+ years'
  ];

  bool _isValidFullName(String name) => name.trim().isNotEmpty;
  bool _isValidLocation(String location) => locations.contains(location);
  bool _isValidExperience(String exp) => experienceOptions.contains(exp);
  bool _isValidDate(String date) {
    final regex = RegExp(r'^(0[1-9]|[12][0-9]|3[01])[\/\-](0[1-9]|1[0-2])[\/\-](19|20)\d{2}$');
    return regex.hasMatch(date.trim());
  }

  Future<void> _saveProfile() async {
    final name = fullNameController.text;
    final dob = dobController.text;
    final designation = selectedDesignation;
    final location = selectedLocation;
    int experienceNum = 0;
    if (selectedExperience == 'Less than 1 year')
      experienceNum = 0;
    else if (selectedExperience == '1 year')
      experienceNum = 1;
    else if (selectedExperience == '2 years')
      experienceNum = 2;
    else if (selectedExperience == '3+ years') experienceNum = 3;


    // Convert dob to ISO format (yyyy-mm-dd) regardless of input separator
    String dobIso = '';
    try {
      String sep = dob.contains('/') ? '/' : (dob.contains('-') ? '-' : '');
      final parts = sep.isNotEmpty ? dob.split(sep) : [];
      if (parts.length == 3) {
        // dd/mm/yyyy or dd-mm-yyyy
        dobIso = '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      } else {
        dobIso = dob; // fallback
      }
    } catch (_) {
      dobIso = dob;
    }

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

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUserData({
      'fullName': name,
      'dateOfBirth': dobIso,
      'designation': designation,
      'location': location,
      'experience': experienceNum,
    });
    try {
      final response = await ApiService().put('/profiles/', {
        'fullName': name,
        'dateOfBirth': dobIso,
        'designation': designation,
        'location': location,
        'experience': experienceNum,
      });
      if (response['success'] == true) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update profile'), backgroundColor: Colors.red),
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
        title: const Text('Edit Overview', style: TextStyle(color: Colors.white)),
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
                            dialogTheme: DialogThemeData(backgroundColor: Color(0xFF23262B)),
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
                const Text(
                  "Designation",
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
                  title: selectedExperience.isEmpty ? "Select Experience" : selectedExperience,
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
                    onPressed: _saveProfile,
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
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, {required String title, required List<String> options, required void Function(String) onSelected}) {
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
  }
}
