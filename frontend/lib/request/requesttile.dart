import 'package:flutter/material.dart';
import 'package:reva/services/service_manager.dart';
import 'package:reva/qr/qr_scan_screen.dart';

class RequestTile extends StatelessWidget {
  final String name;
  final String image;
  final String mobileNumber;
  final String requestId;
  final VoidCallback? onRefresh;

  const RequestTile({
    super.key,
    required this.name,
    required this.image,
    required this.mobileNumber,
    required this.requestId,
    this.onRefresh,
  });

  Future<void> _handleAccept(BuildContext context) async {
    // Navigate to QR scan screen instead of calling accept endpoint
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QrScanScreen(),
      ),
    );
  }

  Future<void> _handleReject(BuildContext context) async {
    try {
      final response = await ServiceManager.instance.connections
          .rejectConnectionRequest(requestId);
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection request rejected'),
            backgroundColor: Colors.orange,
          ),
        );
        // Refresh the requests list
        onRefresh?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to reject request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reject request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
            backgroundImage: AssetImage(image),
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

          // Accept Button
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0262AB), Color(0xFF01345A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(
              onTap: () => _handleAccept(context),
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

          // Reject Button
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(
              onTap: () => _handleReject(context),
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  'Reject',
                  style: TextStyle(
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
