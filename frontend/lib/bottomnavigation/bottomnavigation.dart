import 'package:flutter/material.dart';
import 'package:reva/events/eventscreen.dart';
import 'package:reva/home/homescreen.dart';
import 'package:reva/notification/notification.dart';
import 'package:reva/peopleyoumayknow/peopleyoumayknow.dart';
import 'package:reva/posts/createpost.dart';
import 'package:reva/posts/postsScreen.dart';
import 'package:reva/request/requestscreen.dart';
import 'package:reva/wallet/walletscreen.dart';

import '../contacts/contacts.dart';
import '../dummyscreen.dart';



class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF22252A),
      body: getCurrentScreen(),
      floatingActionButton: Container(
      width: 64, // Adjust size as needed
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF0262AB), Color(0xFF01345A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: RawMaterialButton(
        shape: const CircleBorder(),
        onPressed: () {
          // TODO: Add your FAB action here
        },
        child: const Icon(
          Icons.center_focus_strong_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: const Color(0xFF2A2E35),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(icon: Icons.home, index: 0),
                _buildNavItem(icon: Icons.bar_chart, index: 1),
                const SizedBox(width: 40), // For FAB spacing
                _buildNavItem(icon: Icons.notifications, index: 2),
                _buildNavItem(icon: Icons.person, index: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    return IconButton(
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
      icon: Icon(
        icon,
        color: _currentIndex == index ? Colors.white : Colors.grey[500],
      ),
    );
  }

  Widget getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen();
      case 1:
        return EventScreen();
      case 2:
        return SharePostScreen();
      case 3:
        return DummyScreen();
      default:
        return const SizedBox();
    }
  }
}
