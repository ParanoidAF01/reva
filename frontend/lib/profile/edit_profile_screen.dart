import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../shared/cloudinary_upload.dart';
import '../services/service_manager.dart';
import '../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController locationController;
  late TextEditingController experienceController;
  late TextEditingController languagesController;
  File? pickedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final userData = Provider.of<UserProvider>(context, listen: false).userData;
    locationController = TextEditingController(text: userData?['location'] ?? '');
    String expText = '';
    if (userData?['experience'] != null) {
      expText = userData!['experience'].toString();
    }
    experienceController = TextEditingController(text: expText);
    languagesController = TextEditingController(text: userData?['languages'] ?? '');
  }

  @override
  void dispose() {
    locationController.dispose();
    experienceController.dispose();
    languagesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      String? avatarUrl;
      if (pickedImage != null) {
        avatarUrl = await CloudinaryService.uploadImage(pickedImage!);
        if (avatarUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image to Cloudinary.')),
          );
          setState(() => isLoading = false);
          return;
        }
      }
      final Map<String, dynamic> payload = {
        'location': locationController.text,
        'languages': languagesController.text.trim(),
        if (avatarUrl != null) 'profilePicture': avatarUrl,
      };
      if (experienceController.text.trim().isNotEmpty) {
        final expVal = int.tryParse(experienceController.text.trim());
        if (expVal != null) {
          payload['experience'] = expVal;
        } else {
          payload['experience'] = experienceController.text.trim(); // fallback, but backend expects int
        }
      }
      final response = await ServiceManager.instance.profile.updateProfile(payload);
      if (response['success'] == true) {
        await userProvider.loadUserData();
        await Future.delayed(const Duration(milliseconds: 200));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update profile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context).userData;
    final String? profilePic = userData?['profilePicture'];
    final bool hasProfilePic = profilePic != null && profilePic.isNotEmpty && !profilePic.contains('assets/');
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23262B),
        title: Text('Edit Profile', style: GoogleFonts.dmSans(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: pickedImage != null ? FileImage(pickedImage!) : (hasProfilePic ? NetworkImage(profilePic) as ImageProvider : const AssetImage('assets/dummyprofile.png')),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF0262AB),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(5),
                          child: const Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _editField('Location', locationController),
                  _editField('Experience', experienceController),
                  _editField('Languages', languagesController),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0262AB),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveProfile,
                      child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _editField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF2B2F34)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF0262AB)),
            borderRadius: BorderRadius.circular(12),
          ),
          fillColor: const Color(0xFF23262B),
          filled: true,
        ),
      ),
    );
  }
}
