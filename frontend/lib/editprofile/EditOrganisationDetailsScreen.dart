import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reva/services/api_service.dart';
import 'package:reva/providers/user_provider.dart';
import 'package:reva/authentication/components/mytextfield.dart';
import '../profile/profile_percentage.dart';

class EditOrganisationDetailsScreen extends StatefulWidget {
  const EditOrganisationDetailsScreen({Key? key}) : super(key: key);

  @override
  State<EditOrganisationDetailsScreen> createState() => _EditOrganisationDetailsScreenState();
}

class _EditOrganisationDetailsScreenState extends State<EditOrganisationDetailsScreen> {
  final companyNameController = TextEditingController();
  final incorporationDateController = TextEditingController();
  final gstinController = TextEditingController();
  bool isRegistered = false;
  String selectedCompanyType = 'New Delhi';
  String selectedGstin = '2 years';

  final List<String> companyTypes = [
    'New Delhi',
    'Private Ltd',
    'LLP',
    'Proprietorship'
  ];
  final List<String> gstinOptions = [
    'Less than 1 year',
    '1 year',
    '2 years',
    '3+ years'
  ];

  @override
  void initState() {
    super.initState();
    final userData = Provider.of<UserProvider>(context, listen: false).userData ?? {};
    if (userData['organization'] != null && userData['organization'] is Map) {
      final org = userData['organization'];
      if ((org['name'] ?? '').toString().isNotEmpty) {
        companyNameController.text = org['name'];
      }
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
      if ((org['gstNumber'] ?? '').toString().isNotEmpty) {
        gstinController.text = org['gstNumber'];
      }
      if (org['registered'] != null) {
        isRegistered = org['registered'] == true;
      }
      if ((org['companyType'] ?? '').toString().isNotEmpty) {
        selectedCompanyType = org['companyType'];
      }
    }
  }

  bool _isValidCompanyName(String name) => name.trim().isNotEmpty;
  bool _isValidIncorporationDate(String date) {
    final regex = RegExp(r'^(0[1-9]|[12][0-9]|3[01])[\/\-](0[1-9]|1[0-2])[\/\-](19|20)\d{2}$');
    return regex.hasMatch(date.trim());
  }
  bool _isValidCompanyType(String type) => companyTypes.contains(type);

  Future<void> _saveOrganisationDetails() async {
    final name = companyNameController.text;
    final date = incorporationDateController.text;
    final type = selectedCompanyType;
    // Convert incorporation date to ISO format (yyyy-mm-dd) regardless of input separator
    String dateIso = '';
    try {
      String sep = date.contains('/') ? '/' : (date.contains('-') ? '-' : '');
      final parts = sep.isNotEmpty ? date.split(sep) : [];
      if (parts.length == 3) {
        // dd/mm/yyyy or dd-mm-yyyy
        dateIso = '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      } else {
        dateIso = date; // fallback
      }
    } catch (_) {
      dateIso = date;
    }
    String? error;
    if (!_isValidCompanyName(name)) {
      error = "Please enter your company/firm name.";
    } else if (!_isValidIncorporationDate(date)) {
      error = "Please enter a valid incorporation date (dd/mm/yyyy).";
    } else if (!isRegistered) {
      error = "Please confirm your company is registered.";
    } else if (!_isValidCompanyType(type)) {
      error = "Please select a valid company type.";
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUserData({
      'organization': {
        'name': companyNameController.text,
        'incorporationDate': dateIso,
        'gstNumber': gstinController.text,
        'registered': isRegistered,
        'companyType': selectedCompanyType,
      }
    });
    try {
      final response = await ApiService().put('/profiles/', {
        'organization': {
          'name': companyNameController.text,
          'incorporationDate': dateIso,
          'gstNumber': gstinController.text,
          'registered': isRegistered,
          'companyType': selectedCompanyType,
        }
      });
      if (response['success'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfilePercentageScreen()),
          (route) => false,
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
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final padding = width * 0.06;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22252A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Edit Organisation Details', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.06),
                CustomTextField(
                  label: 'Company/Firm Name',
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
                      label: 'Incorporation Date',
                      hint: '09/09/2003',
                      controller: incorporationDateController,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildBottomSheetField(
                  label: 'Company Type',
                  value: selectedCompanyType,
                  options: companyTypes,
                  onSelected: (val) {
                    setState(() => selectedCompanyType = val);
                  },
                ),
                const SizedBox(height: 16),
                _buildBottomSheetField(
                  label: 'GSTIN (Optional)',
                  value: selectedGstin,
                  options: gstinOptions,
                  onSelected: (val) {
                    setState(() => selectedGstin = val);
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveOrganisationDetails,
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
}
