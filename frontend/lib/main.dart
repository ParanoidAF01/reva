import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'root_redirector.dart';
import 'notification/notification.dart';
import 'wallet/walletscreen.dart';
import 'providers/user_provider.dart';
import 'contacts/contacts.dart';
import 'request/requestscreen.dart';

import 'authentication/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'REVA',
        debugShowCheckedModeBanner: false,
        home: const RootRedirector(),
        routes: {
          '/notification': (context) => const NotificationScreen(),
          '/wallet': (context) => const WalletScreen(),
          '/contacts': (context) => const Contacts(),
          '/requests': (context) => const RequestScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}
