import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reva/events/eventscreen.dart';
import 'package:reva/home/homescreen.dart';

import 'package:reva/profile/profile_screen.dart';

import 'package:reva/posts/postsScreen.dart';

import 'package:reva/qr/qr_scan_screen.dart';
import 'package:reva/providers/user_provider.dart';

class BottomNavigation extends StatefulWidget {
  final int initialIndex;
  const BottomNavigation({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserData();
    await userProvider.checkSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex == 0) {
          // Exit app if on home tab
          return true;
        } else {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF22252A),
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
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QrScanScreen()),
              );
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
                  _buildNavItem(icon: Icons.post_add, index: 2),
                  _buildNavItem(icon: Icons.person, index: 3),
                ],
              ),
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
        return const HomeScreen();
      case 1:
        return const EventScreen();
      case 2:
        return const PostsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox();
    }
  }
}
