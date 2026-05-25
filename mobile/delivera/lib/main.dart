import 'package:flutter/material.dart';

import 'screens/login.dart';
import 'screens/trips/trips_home.dart';
import 'session.dart';
import 'themes/lightTheme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Session.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Session.isLoggedIn ? const TripsHomePage() : const LoginPage(),
    );
  }
}
