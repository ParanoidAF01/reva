import 'package:flutter/material.dart';
import 'package:reva/services/service_manager.dart';

class ProfileModal extends StatelessWidget {
  final String name;
  final String image;
  final String userId;
  final String mobileNumber;
  final bool isConnection; // true if this is a contact, false if suggestion

  const ProfileModal({
    super.key,
    required this.name,
    required this.image,
    required this.userId,
    required this.mobileNumber,
    this.isConnection = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF23303E), Color(0xFF1B232B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Spacer(),
              Text(
                isConnection ? 'Contact Profile' : 'Profile',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: width * 0.13,
                backgroundImage: AssetImage(image),
              ),
              if (!isConnection)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.lock,
                        color: Color(0xFF01416A), size: 22),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          Text(
            mobileNumber,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 10),

          // Show different buttons based on whether it's a connection or suggestion
          if (!isConnection) ...[
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01416A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 0,
                ),
                child: const Text(
                  'Connect',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('• Experience: 5+ years',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(width: 8),
                Text('• Languages: English, Hindi',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23262B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Real Estate',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23262B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Investment',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ProfileStatBox(
                    icon: Icons.people,
                    value: '150+',
                    label: 'Total Connections'),
                const SizedBox(width: 16),
                _ProfileStatBox(
                    icon: Icons.celebration,
                    value: '25+',
                    label: 'Events Attended'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text(mobileNumber,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 15)),
                const SizedBox(width: 18),
                const Icon(Icons.email, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text('user@example.com',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 18),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat, color: Colors.white, size: 22),
                SizedBox(width: 16),
                Icon(Icons.facebook, color: Colors.white, size: 22),
                SizedBox(width: 16),
                Icon(Icons.photo_camera, color: Colors.white, size: 22),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                print('PROFILE MODAL - Sending connection request:');
                print('userId: $userId');

                try {
                  final response = await ServiceManager.instance.connections
                      .sendConnectionRequest(userId);
                  if (response['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Connection request sent!')),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            response['message'] ?? 'Error sending request'),
                      ),
                    );
                  }
                } catch (e) {
                  print('PROFILE MODAL - Error sending request: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to send connection request')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0262AB),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Send Connection Request',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ] else ...[
            // For connections, show contact info and actions
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('• Connected since: 2 months ago',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(width: 8),
                Text('• Last contact: 2 days ago',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ProfileStatBox(
                    icon: Icons.phone, value: '12', label: 'Calls Made'),
                const SizedBox(width: 16),
                _ProfileStatBox(
                    icon: Icons.message, value: '8', label: 'Messages'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text(mobileNumber,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 15)),
                const SizedBox(width: 18),
                const Icon(Icons.email, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text('contact@example.com',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement call functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling...')),
                    );
                  },
                  icon: const Icon(Icons.phone, color: Colors.white),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement message functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening chat...')),
                    );
                  },
                  icon: const Icon(Icons.message, color: Colors.white),
                  label: const Text('Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0262AB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileStatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ProfileStatBox(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF23262B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
