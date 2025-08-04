import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:reva/services/service_manager.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  String? scannedData;
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final frameSize = width * 0.65;
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
                'Hello!',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              IconButton(
                icon:
                    const Icon(Icons.notifications_none, color: Colors.white54),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final left = (w - frameSize) / 2;
          final top = h * 0.18;
          return Stack(
            children: [
              // Opaque background
              Container(color: const Color(0xFF22252A)),
              // Card with border and blue corners, camera preview only inside card
              Positioned(
                left: left,
                top: top,
                child: Container(
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
                      // Camera preview only inside card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: MobileScanner(
                          controller: MobileScannerController(),
                          onDetect: (capture) async {
                            if (isScanned) return;
                            final List<Barcode> barcodes = capture.barcodes;
                            if (barcodes.isNotEmpty &&
                                barcodes.first.rawValue != null) {
                              setState(() {
                                scannedData = barcodes.first.rawValue;
                                isScanned = true;
                              });

                              // Log what QR sees
                              print('QR SCAN DEBUG:');
                              print('Raw QR Data: ${barcodes.first.rawValue}');
                              print('Barcode Type: ${barcodes.first.type}');
                              print('Format: ${barcodes.first.format}');

                              // Parse QR data to extract phone number
                              String? phoneNumber;
                              String rawData = barcodes.first.rawValue!;

                              if (rawData.contains('phone:')) {
                                // Extract phone number from "mpin:xxx,phone:xxx" format
                                final phoneMatch =
                                    RegExp(r'phone:(\d+)').firstMatch(rawData);
                                if (phoneMatch != null) {
                                  phoneNumber = phoneMatch.group(1);
                                  print('Extracted Phone Number: $phoneNumber');
                                }
                              } else {
                                // Assume raw data is phone number
                                phoneNumber = rawData;
                                print(
                                    'Using raw data as phone number: $phoneNumber');
                              }

                              // Handle QR connection
                              try {
                                final response = await ServiceManager
                                    .instance.connections
                                    .connectViaQR({
                                  'mobileNumber': phoneNumber ?? scannedData!,
                                });

                                if (response['success'] == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Successfully connected with ${response['data']['connectedUser']['fullName']}'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response['message'] ??
                                          'Connection failed'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }

                              Navigator.pop(context, scannedData);
                            }
                          },
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
                              top: BorderSide(
                                  color: Color(0xFF1976D2), width: 4),
                              left: BorderSide(
                                  color: Color(0xFF1976D2), width: 4),
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
                              top: BorderSide(
                                  color: Color(0xFF1976D2), width: 4),
                              right: BorderSide(
                                  color: Color(0xFF1976D2), width: 4),
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
                              bottom: BorderSide(
                                  color: Color(0xFF1976D2), width: 4),
                              left: BorderSide(
                                  color: Color(0xFF1976D2), width: 4),
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
                              bottom: BorderSide(
                                  color: Color(0xFF1976D2), width: 4),
                              right: BorderSide(
                                  color: Color(0xFF1976D2), width: 4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Info below QR
              Positioned(
                left: left,
                top: top + frameSize + 24,
                width: frameSize,
                child: const Column(
                  children: [
                    Text(
                      'Ayush Kumar.',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Delhi NCR',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Row(
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
            ],
          );
        },
      ),
    );
  }
}
