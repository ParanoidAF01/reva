import 'package:flutter/material.dart';
import '../main.dart';
import '../authentication/welcomescreen.dart';

class NavigationHelper {
  // Global method to show SnackBar without context with delay
  static void showSnackBar(String message,
      {Color? backgroundColor, Duration? delay}) {
    final actualDelay = delay ?? const Duration(milliseconds: 100);

    Future.delayed(actualDelay, () {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    });
  }

  // Global method to navigate without context
  static void navigateTo(Widget screen) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  // Global method to navigate and remove all previous routes
  static void navigateAndRemoveAll(Widget screen) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => screen),
        (route) => false,
      );
    }
  }

  // Global method to navigate to welcome screen
  static void navigateToWelcomeScreen() {
    navigateAndRemoveAll(const WelcomeScreen());
  }

  // Global method to pop current screen
  static void pop() {
    final context = navigatorKey.currentContext;
    if (context != null && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
