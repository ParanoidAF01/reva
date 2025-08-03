import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'authentication/welcomescreen.dart';
import 'root_redirector.dart';
import 'notification/notification.dart';
import 'providers/user_provider.dart';

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
        },
      ),
    );
  }
}
