import 'package:flutter/material.dart';
import 'package:reva/services/service_manager.dart';
import 'package:reva/qr/qr_scan_screen.dart';

class RequestTile extends StatelessWidget {
  Future<void> _handleScanQR(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QrScanScreen(),
      ),
    );
  }

  final Map<String, dynamic> userData;
  final String requestId;
  final VoidCallback? onRefresh;
  final bool isOutgoing;

  const RequestTile({
    super.key,
    required this.userData,
    required this.requestId,
    this.onRefresh,
    this.isOutgoing = false,
  });

  Future<void> _handleAccept(BuildContext context) async {
    // Accept only for incoming requests
    // You may want to call respondToConnectionRequest here if needed
    // For now, just refresh
    onRefresh?.call();
  }

  Future<void> _handleRejectOrCancel(BuildContext context) async {
    try {
      Map<String, dynamic> response;
      if (isOutgoing) {
        response = await ServiceManager.instance.connections.cancelConnectionRequest(requestId);
      } else {
        response = await ServiceManager.instance.connections.rejectConnectionRequest(requestId);
      }
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isOutgoing ? 'Request cancelled' : 'Connection request rejected'),
            backgroundColor: isOutgoing ? Colors.red : Colors.orange,
          ),
        );
        onRefresh?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? (isOutgoing ? 'Failed to cancel request' : 'Failed to reject request')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isOutgoing ? 'Failed to cancel request' : 'Failed to reject request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final String name = userData['fullName'] ?? 'Unknown';
    final String mobileNumber = userData['mobileNumber'] ?? '';
    String? profilePic;
    String? designation;
    String? location;
    String? organization;
    final profileField = userData['profile'];
    if (profileField is Map<String, dynamic>) {
      profilePic = profileField['profilePicture'] is String ? profileField['profilePicture'] as String : null;
      designation = profileField['designation'] is String ? profileField['designation'] as String : null;
      location = profileField['location'] is String ? profileField['location'] as String : null;
      organization = profileField['organization'] is String ? profileField['organization'] as String : null;
    } else {
      profilePic = null;
      designation = null;
      location = null;
      organization = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3237),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            radius: width * 0.06,
            backgroundImage: (profilePic != null && profilePic.isNotEmpty) ? NetworkImage(profilePic) : AssetImage('assets/dummyprofile.png') as ImageProvider,
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
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (designation != null && designation.isNotEmpty)
                  Text(
                    designation,
                    style: const TextStyle(
                      color: Color(0xFFB2B8BD),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                if (organization != null && organization.isNotEmpty)
                  Text(
                    organization,
                    style: const TextStyle(
                      color: Color(0xFFB2B8BD),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                if (location != null && location.isNotEmpty)
                  Text(
                    location,
                    style: const TextStyle(
                      color: Color(0xFFB2B8BD),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
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
              ],
            ),
          ),

          // Scan QR Button for both incoming and outgoing requests
          Container(
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
              onTap: () => _handleScanQR(context),
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  'Scan QR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Reject/Cancel Button
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(
              onTap: () => _handleRejectOrCancel(context),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  isOutgoing ? 'Cancel' : 'Reject',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
