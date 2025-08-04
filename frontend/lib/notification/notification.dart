import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/notification/notificationTile.dart';
import 'package:reva/notification/notification_model.dart';
import '../services/service_manager.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final response =
          await ServiceManager.instance.notifications.getMyNotifications();
      if (response['success'] == true) {
        final List<dynamic> notificationsData =
            response['data']['notifications'] ?? [];
        notifications = notificationsData
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      } else {
        error = response['message'] ?? 'Failed to load notifications';
      }
    } catch (e) {
      error = e.toString();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: height * 0.025, left: 16, right: 16, bottom: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF23262B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Notifications",
                    style: GoogleFonts.dmSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? Center(
                          child: Text(error!,
                              style: const TextStyle(color: Colors.red)))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: width * 0.05, vertical: 8),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) => NotificationTile(
                              notification: notifications[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class TriangleIcon extends StatelessWidget {
  final double size;
  final Color color;

  const TriangleIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: TrianglePainter(color),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
