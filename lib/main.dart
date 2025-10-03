import 'package:fiverr/features/notifications/presentation/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:fiverr/features/auth/presentation/screens/login_screen.dart';
import 'package:fiverr/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:fiverr/features/main/presentation/screens/main_screen.dart';
import 'package:fiverr/features/splash/presentation/screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fiverr App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/main': (context) => MainScreen(),
        '/signup': (context) => SignUpScreen(),
        '/notifications': (_) => const NotificationsPage(),
      },
    );
  }
}
