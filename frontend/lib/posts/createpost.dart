import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import '../services/service_manager.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class SharePostScreen extends StatelessWidget {
  const SharePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final TextEditingController postController = TextEditingController();
    XFile? pickedFile;
    String? pickedType;
    int usedPosts = 0;
    int maxPosts = 2;

    return FutureBuilder(
      future: ServiceManager.instance.posts.getMyPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final posts = (snapshot.data as Map<String, dynamic>)['data']?['posts'] ?? [];
        usedPosts = posts.length;
        return StatefulBuilder(
          builder: (context, setState) => Scaffold(
            backgroundColor: const Color(0xFF22252A),
            body: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: height * 0.03),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        Text("Share post", style: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Profile Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Builder(
                          builder: (context) {
                            final userProvider = Provider.of<UserProvider>(context, listen: false);
                            final profilePic = userProvider.userData?['profilePicture'] ?? userProvider.userData?['profileImage'] ?? 'assets/dummyprofile.png';
                            return CircleAvatar(
                              radius: 24,
                              backgroundImage: profilePic != null && profilePic.toString().isNotEmpty && !profilePic.toString().contains('assets/') ? NetworkImage(profilePic) : const AssetImage('assets/dummyprofile.png') as ImageProvider,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Builder(
                          builder: (context) {
                            final userProvider = Provider.of<UserProvider>(context, listen: false);
                            final userName = userProvider.userName;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "$usedPosts/$maxPosts Posts",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            );
                          },
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0262AB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: usedPosts >= maxPosts
                              ? null
                              : () async {
                                  final text = postController.text.trim();
                                  if (text.isNotEmpty || pickedFile != null) {
                                    try {
                                      final postData = {
                                        'content': text,
                                        'mediaType': pickedFile != null ? (pickedType == 'photo' ? 'image' : 'video') : null,
                                        'mediaPath': pickedFile?.path,
                                      };

                                      final response = await ServiceManager.instance.posts.createPost(postData);
                                      if (response['success'] == true) {
                                        Navigator.of(context).pop();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(response['message'] ?? 'Failed to create post')),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error creating post: $e')),
                                      );
                                    }
                                  }
                                },
                          child: const Text(
                            "Post",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Prompt Text
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: postController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                      decoration: const InputDecoration(
                        hintText: "What do you want to talk about?",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 24),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (pickedFile != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: pickedType == 'photo'
                          ? Image.file(
                              File(pickedFile!.path),
                              height: 120,
                            )
                          : Container(
                              height: 120,
                              color: Colors.black26,
                              child: const Center(child: Text('Video selected', style: TextStyle(color: Colors.white))),
                            ),
                    ),
                  const Spacer(),
                  // Bottom Container
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2F343A),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? file = await picker.pickImage(source: ImageSource.gallery);
                            if (file != null) {
                              setState(() {
                                pickedFile = file;
                                pickedType = 'photo';
                              });
                            }
                          },
                          child: _buildOption(Iconsax.gallery, "Add a photo", highlight: true),
                        ),
                        InkWell(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
                            if (file != null) {
                              setState(() {
                                pickedFile = file;
                                pickedType = 'video';
                              });
                            }
                          },
                          child: _buildOption(Iconsax.video, "Take a video", highlight: true),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              postController.text = "🎉 I'm celebrating a special occasion! Details: ";
                            });
                          },
                          child: _buildOption(Iconsax.award, "Celebrate an occasion", highlight: false),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              postController.text = "📄 Sharing a document: [Document Name/Details]";
                            });
                          },
                          child: _buildOption(Iconsax.document, "Add a document", highlight: false),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              postController.text = "💼 We're hiring! Position: [Role], Details: ";
                            });
                          },
                          child: _buildOption(Iconsax.briefcase, "Share that you’re hiring", highlight: false),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              postController.text = "🔍 Looking for an expert in: [Field/Skill]";
                            });
                          },
                          child: _buildOption(Iconsax.people, "Find an expert", highlight: false),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              postController.text = "📊 Poll: [Your question here]\n1. Option 1\n2. Option 2";
                            });
                          },
                          child: _buildOption(Iconsax.chart, "Create a poll", highlight: false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption(IconData icon, String label, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: highlight ? Colors.white : Colors.grey.shade300),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: highlight ? Colors.white : Colors.grey.shade300,
              fontSize: 16,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
