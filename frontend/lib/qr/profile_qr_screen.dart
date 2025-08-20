import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:reva/providers/user_provider.dart';

class ProfileQrScreen extends StatelessWidget {
  final String mpin;
  final String phone;
  final String name;
  const ProfileQrScreen(
      {super.key, required this.mpin, required this.phone, required this.name});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final frameSize = width * 0.65;
    final qrData = 'phone:$phone';
    final userData = context.watch<UserProvider>().userData;
    final String userLocation =
        (userData?['location'] ?? userData?['user']?['location'] ?? '')
            .toString();
    print('QR GENERATION DEBUG:');
    print('Phone: $phone');
    print('QR Data: $qrData');
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: const Color(0xFF22252A),
          padding: const EdgeInsets.only(top: 32, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile QR',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: frameSize,
              height: frameSize,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF23262B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: PrettyQr(
                      data: qrData,
                      roundEdges: true,
                      elementColor: const Color(0xFF1976D2),
                      size: frameSize - 36,
                    ),
                  ),
                  // Blue corners
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFF1976D2), width: 4),
                          left: BorderSide(color: Color(0xFF1976D2), width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFF1976D2), width: 4),
                          right: BorderSide(color: Color(0xFF1976D2), width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Color(0xFF1976D2), width: 4),
                          left: BorderSide(color: Color(0xFF1976D2), width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Color(0xFF1976D2), width: 4),
                          right: BorderSide(color: Color(0xFF1976D2), width: 4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              userLocation,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                SizedBox(width: 6),
                Text(
                  'KYC approved',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
