import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/notification/notificationTile.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var height= MediaQuery.of(context).size.height;
    var width= MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFF22252A),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width*0.05,),
          child: Column(
            children: [
              SizedBox(height: height*0.1,),
              Row(
                children: [
                  InkWell(
                      onTap: (){},
                      child: TriangleIcon(size: 20 , color: Colors.white,)),
                  SizedBox(width: width*0.22,),
                  Text("Notifications", style: GoogleFonts.dmSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white
                  ),)

                ],
              ),
              NotificationTile(),
              NotificationTile(),
              NotificationTile(),
            ],
          ),
        ),
      ),
    );
  }
}
class TriangleIcon extends StatelessWidget {
  final double size;
  final Color color;

  TriangleIcon({super.key, this.size = 24, this.color = Colors.white});

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

