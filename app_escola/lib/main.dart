import 'package:flutter/material.dart';
import 'package:app_escola/screens/home/home.dart';
import 'package:app_escola/screens/user/user.dart';
import 'package:app_escola/screens/activity/activity.dart';
import 'package:app_escola/screens/user_activity/user_activity.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/user': (context) => const UserScreen(),
        '/activity': (context) => const ActivityScreen(),
        '/user-activity': (context) => const UserActivityScreen(),
      },
    );
  }
}
