import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PeopleYouMayKnowCard extends StatelessWidget {
  final String name;
  final String image;
  final String userId;
  const PeopleYouMayKnowCard({super.key, required this.name, required this.image, required this.userId});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Center(
      child: SizedBox(
        width: width * 0.38,
        height: width * 0.56,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: AssetImage('assets/peopleyoumayknowtile_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock, color: Colors.white, size: 16),
                  ),
                ],
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 1, bottom: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: CircleAvatar(
                    radius: width * 0.08,
                    backgroundImage: AssetImage(image),
                  ),
                ),
              ),
              Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
              ),
              const SizedBox(height: 0.5),
              const Center(
                child: Text(
                  'buyer/seller/\ninvestor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB1B5BA),
                    fontSize: 11.5,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Mumbai',
                    style: TextStyle(
                      color: Color(0xFFB1B5BA),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                        child: _ProfilePreviewCard(
                          name: name,
                          location: 'Mumbai',
                          experience: '******',
                          languages: '******',
                          tags: [],
                          totalConnections: '******',
                          eventsAttended: '******',
                          phone: '******',
                          email: '******',
                          image: image,
                          userId: userId,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01416A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 0,
                  ),
                  child: const Text('Connect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePreviewCard extends StatelessWidget {
  final String name;
  final String location;
  final String experience;
  final String languages;
  final List<String> tags;
  final String totalConnections;
  final String eventsAttended;
  final String phone;
  final String email;
  final String image;
  final String userId;
  const _ProfilePreviewCard({
    super.key,
    required this.name,
    required this.location,
    required this.experience,
    required this.languages,
    required this.tags,
    required this.totalConnections,
    required this.eventsAttended,
    required this.phone,
    required this.email,
    required this.image,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = TextEditingController();
    final width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF23303E),
            Color(0xFF1B232B)
          ],
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
              const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
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
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.lock, color: Color(0xFF01416A), size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22)),
          Text(location, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 10),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01416A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.symmetric(vertical: 6),
                elevation: 0,
              ),
              child: const Text('Connect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('• $experience', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(width: 8),
              Text('• $languages', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: tags
                .map((tag) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF23262B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ProfileStatBox(icon: Icons.people, value: totalConnections, label: 'Total Connections'),
              const SizedBox(width: 16),
              _ProfileStatBox(icon: Icons.celebration, value: eventsAttended, label: 'Events Attended'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(phone, style: const TextStyle(color: Colors.white70, fontSize: 15)),
              const SizedBox(width: 18),
              const Icon(Icons.email, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(email, style: const TextStyle(color: Colors.white70, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat, color: Colors.white, size: 22), // WhatsApp alternative
              SizedBox(width: 16),
              Icon(Icons.facebook, color: Colors.white, size: 22),
              SizedBox(width: 16),
              Icon(Icons.photo_camera, color: Colors.white, size: 22), // Camera alternative
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final response = await sendConnectionRequest(userId, messageController.text);
              print('Connection request response:');
              print(response);
              if (response['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connection request sent!')),
                );
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response['message'] ?? 'Error sending request')),
                );
              }
            },
            child: const Text('Send Connection Request'),
          ),
          TextField(
            controller: messageController,
            decoration: const InputDecoration(hintText: 'Add a message (optional)'),
          ),
        ],
      ),
    );
  }
}

Future<Map<String, dynamic>> sendConnectionRequest(String toUserId, String message) async {
  // Use the common API service and access token from secure storage
  final url = Uri.parse('https://reva-pwsw.onrender.com/api/v1/connection/request');
  final storage = const FlutterSecureStorage();
  final accessToken = await storage.read(key: 'accessToken');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer ${accessToken ?? ''}',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'toUserId': toUserId,
      'message': message,
    }),
  );
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> getSentConnectionRequests(String jwt) async {
  final url = Uri.parse('https://reva-pwsw.onrender.com/api/v1/connection/sent-requests');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $jwt',
    },
  );
  return jsonDecode(response.body);
}

class _ProfileStatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _ProfileStatBox({required this.icon, required this.value, required this.label});
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
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
