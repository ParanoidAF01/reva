import 'package:flutter/material.dart';

class WalletTile extends StatelessWidget {
  const WalletTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3339),
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage("assets/logo.png"),
            backgroundColor: Colors.transparent,
          ),
          SizedBox(width: 12),

          // Title and Date Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reva",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Send • August 08, 2023",
                  style: TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Amount and Status Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹3",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Success",
                style: TextStyle(
                  color: Color(0xFF4CAF50), // green
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
