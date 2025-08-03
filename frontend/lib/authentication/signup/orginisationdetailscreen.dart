import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/signup/ekycscreen.dart';
import '../components/mytextfield.dart';

class OrganisationDetailsScreen extends StatefulWidget {
  const OrganisationDetailsScreen({super.key});

  @override
  State<OrganisationDetailsScreen> createState() => _OrganisationDetailsScreenState();
}

class _OrganisationDetailsScreenState extends State<OrganisationDetailsScreen> {
  final companyNameController = TextEditingController();
  final incorporationDateController = TextEditingController();
  final gstinController = TextEditingController();

  bool isRegistered = false;

  String selectedCompanyType = 'New Delhi';
  String selectedGstin = '2 years';

  final List<String> companyTypes = ['New Delhi', 'Private Ltd', 'LLP', 'Proprietorship'];
  final List<String> gstinOptions = ['Less than 1 year', '1 year', '2 years', '3+ years'];

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
                      style: GoogleFonts.dmSans(
                          color: const Color(0xFFD8D8DD),
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
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
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF0262AB)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // CustomTextFields
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

                CustomTextField(
                  label: 'Incorporation Date',
                  hint: '09/09/2003',
                  controller: incorporationDateController,
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGradientButton('Skip', width, (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const EKycScreen()));
                    }),
                    _buildGradientButton('Next', width, (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const EKycScreen()));
                    }),
                  ],
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

  Widget _buildGradientButton(String label, double width,void Function()? onTap ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: (width - (width * 0.12) - 8) / 2,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [Color(0xFF0262AB), Color(0xFF01345A)],
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
