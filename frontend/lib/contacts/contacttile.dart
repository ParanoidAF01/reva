import 'package:reva/profile/dynamic_profile_screen.dart';
import 'package:reva/services/service_manager.dart';
import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  Future<void> _viewProfile(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final userId = contact['_id'] ?? contact['userId'] ?? contact['user']?['_id'];
      final response = await ServiceManager.instance.profile.getProfileById(userId);
      Navigator.of(context).pop(); // Remove loading
      if (response['success'] == true && response['data'] != null) {
        final userData = response['data'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DynamicProfileScreen(
              userInfo: userData,
              totalConnections: userData['totalConnections'] ?? 0,
              eventsAttended: userData['eventsAttended'] ?? 0,
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile')),
      );
    }
  }

  final Map<String, dynamic> contact;
  final VoidCallback? onRemove;

  const ContactTile({
    super.key,
    required this.contact,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final String name = contact['fullName'] ?? 'Unknown';
    final String image = contact['profile'] is Map && contact['profile']['profilePicture'] is String && contact['profile']['profilePicture'].isNotEmpty
        ? contact['profile']['profilePicture']
        : contact['profile'] is String && contact['profile'].isNotEmpty
            ? contact['profile']
            : 'assets/dummyprofile.png';
    final String mobileNumber = contact['mobileNumber'] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3237),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          CircleAvatar(
            radius: width * 0.06,
            backgroundImage: image.isNotEmpty && !image.contains('assets/') ? NetworkImage(image) : AssetImage('assets/dummyprofile.png') as ImageProvider,
          ),
          const SizedBox(width: 12),
          // Name & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  mobileNumber,
                  style: const TextStyle(
                    color: Color(0xFFB2B8BD),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Last contacted: 2 days ago',
                  style: TextStyle(
                    color: Color(0xFF8A9299),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Status: Active',
                  style: TextStyle(
                    color: Color(0xFF8A9299),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Notes: Interested in 3BHK, prefers morning calls.',
                  style: TextStyle(
                    color: Color(0xFF8A9299),
                    fontSize: 11.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // View and Remove Buttons
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0262AB),
                      Color(0xFF01345A)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: InkWell(
                  onTap: () => _viewProfile(context),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child: Text(
                      'View',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFAB0202),
                      Color(0xFF5A0101)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child: Text(
                      'Remove',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
