import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reva/authentication/signup/ekycscreen.dart';
import '../components/mytextfield.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrganisationDetailsScreen extends StatefulWidget {
  final bool showBack;
  const OrganisationDetailsScreen({Key? key, this.showBack = false}) : super(key: key);

  @override
  State<OrganisationDetailsScreen> createState() => _OrganisationDetailsScreenState();
}

class _OrganisationDetailsScreenState extends State<OrganisationDetailsScreen> {
  final companyNameController = TextEditingController();
  final incorporationDateController = TextEditingController();
  final gstinController = TextEditingController();

  final List<String> companyTypes = [
    'Private Limited',
    'Public Limited',
    'LLP',
    'Partnership',
    'Other',
    'Not Applicable',
  ];
  String selectedCompanyType = 'Private Limited';
  // GSTIN is now a free-form text field, so options are removed
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    _loadPrefilledData();
    companyNameController.addListener(_saveFormData);
    incorporationDateController.addListener(_saveFormData);
    gstinController.addListener(_saveFormData);
  }

  Future<void> _loadPrefilledData() async {
    final prefs = await SharedPreferences.getInstance();
    final companyName = prefs.getString('signup_companyName');
    final incorporationDate = prefs.getString('signup_incorporationDate');
    final companyType = prefs.getString('signup_companyType');
    final gstin = prefs.getString('signup_gstin');

    if (companyName != null && companyName.isNotEmpty) {
      companyNameController.text = companyName;
    } else {
      final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
      if (userData['organization'] != null && userData['organization'] is Map) {
        final org = userData['organization'];
        if ((org['name'] ?? '').toString().isNotEmpty) {
          companyNameController.text = org['name'];
        }
      }
    }
    if (incorporationDate != null && incorporationDate.isNotEmpty) {
      incorporationDateController.text = incorporationDate;
    } else {
      final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
      if (userData['organization'] != null && userData['organization'] is Map) {
        final org = userData['organization'];
        if ((org['incorporationDate'] ?? '').toString().isNotEmpty) {
          final dateRaw = org['incorporationDate'];
          String? formattedDate;
          if (dateRaw is String && dateRaw.isNotEmpty) {
            DateTime? dt;
            try {
              dt = DateTime.tryParse(dateRaw);
            } catch (_) {}
            if (dt != null) {
              formattedDate = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
            } else if (dateRaw.contains('-')) {
              final parts = dateRaw.split('-');
              if (parts.length == 3) {
                formattedDate = '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
              }
            }
            formattedDate ??= dateRaw;
            incorporationDateController.text = formattedDate;
          }
        }
      }
    }
    if (companyType != null && companyType.isNotEmpty && companyTypes.contains(companyType)) {
      setState(() {
        selectedCompanyType = companyType;
      });
    } else {
      final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
      if (userData['organization'] != null && userData['organization'] is Map) {
        final org = userData['organization'];
        if ((org['companyType'] ?? '').toString().isNotEmpty && companyTypes.contains(org['companyType'])) {
          setState(() {
            selectedCompanyType = org['companyType'];
          });
        }
      }
    }
    if (gstin != null && gstin.isNotEmpty) {
      gstinController.text = gstin;
    } else {
      final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
      if (userData['organization'] != null && userData['organization'] is Map) {
        final org = userData['organization'];
        if ((org['gstNumber'] ?? '').toString().isNotEmpty) {
          gstinController.text = org['gstNumber'];
        }
      }
    }
    setState(() {});
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('signup_companyName', companyNameController.text);
    await prefs.setString('signup_incorporationDate', incorporationDateController.text);
    await prefs.setString('signup_companyType', selectedCompanyType);
    await prefs.setString('signup_gstin', gstinController.text);
  }

  // Validation helpers
  bool _isValidCompanyName(String name) => name.trim().isNotEmpty;
  bool _isValidIncorporationDate(String date) {
    final regex = RegExp(r'^(0[1-9]|[12][0-9]|3[01])[\/\-](0[1-9]|1[0-2])[\/\-](19|20)\d{2}$');
    return regex.hasMatch(date.trim());
  }

  bool _isValidCompanyType(String type) => companyTypes.contains(type);

  Future<void> _validateAndProceed() async {
    final name = companyNameController.text;
    final date = incorporationDateController.text;
    final type = selectedCompanyType;

    String? error;
    if (!_isValidCompanyName(name)) {
      error = "Please enter your company/firm name.";
    } else if (!_isValidIncorporationDate(date)) {
      error = "Please enter a valid incorporation date (dd/mm/yyyy).";
    } else if (!_isValidCompanyType(type)) {
      error = "Please select a valid company type.";
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    // Save to provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Convert incorporationDate to ISO format (yyyy-mm-dd) if possible
    String rawDate = incorporationDateController.text.trim();
    String isoDate = rawDate;
    final dateRegex = RegExp(r'^(\d{2})[\/\-](\d{2})[\/\-](\d{4})$');
    final match = dateRegex.firstMatch(rawDate);
    if (match != null) {
      // dd/mm/yyyy or dd-mm-yyyy to yyyy-mm-dd
      isoDate = '${match.group(3)}-${match.group(2)}-${match.group(1)}';
    }
    final String? companyTypeToSend = (selectedCompanyType == 'Not Applicable') ? null : selectedCompanyType;
    userProvider.updateUserData({
      'organization': {
        'name': companyNameController.text,
        'incorporationDate': isoDate,
        'gstNumber': gstinController.text,
        'registered': isRegistered,
        'companyType': companyTypeToSend,
      }
    });
    // Save to shared_preferences for persistence
    await _saveFormData();
    // Debug print for endpoint and payload
    final endpoint = '/profiles/';
    final payload = {
      'organization': {
        'name': companyNameController.text,
        'incorporationDate': isoDate,
        'gstNumber': gstinController.text,
        'registered': isRegistered,
        'companyType': companyTypeToSend,
      }
    };
    // ignore: avoid_print
    print('PUT request to: ' + endpoint);
    // ignore: avoid_print
    print('Payload: ' + payload.toString());
    // Send to backend with correct structure
    try {
      final response = await ApiService().put(endpoint, payload);
      if (response['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EKycScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update organization details'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    companyNameController.dispose();
    incorporationDateController.dispose();
    gstinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final padding = width * 0.06;

    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.06),
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
                    'Organisation Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Progress indicator
                Row(
                  children: [
                    Text(
                      "20%   ",
                      style: GoogleFonts.dmSans(color: const Color(0xFFD8D8DD), fontSize: 18, fontWeight: FontWeight.w700),
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
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: width * 0.6,
                    child: const LinearProgressIndicator(
                      value: 0.2,
                      minHeight: 6,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0262AB)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // CustomTextFields
                CustomTextField(
                  label: 'Company / Individual Name',
                  hint: 'xyw company',
                  controller: companyNameController,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Registered Company',
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
                        value: isRegistered,
                        onChanged: (val) {
                          setState(() => isRegistered = val);
                        },
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
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
                        incorporationDateController.text = formatted;
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: CustomTextField(
                      label: 'Incorporation Date / Birth Date',
                      hint: '09/09/2003',
                      controller: incorporationDateController,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildBottomSheetField(
                  label: 'Company Type (Select N/A if Individual)',
                  value: selectedCompanyType,
                  options: companyTypes,
                  onSelected: (val) {
                    setState(() => selectedCompanyType = val);
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'GSTIN (Optional)',
                  hint: 'Enter GSTIN (if any)',
                  controller: gstinController,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: _buildGradientButton('Next', width, _validateAndProceed),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _buildGradientButton(String label, double width, void Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: (width - (width * 0.12) - 8) / 2,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0262AB),
              Color(0xFF01345A)
            ],
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
