import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/todo_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');
  final username = prefs.getString('username');
  final email = prefs.getString('email');

  Widget initialScreen;

  if (userId != null && username != null && email != null) {
    initialScreen = TodoScreen(userId: userId, username: username, email: email);
  } else {
    initialScreen = const LoginScreen();
  }
  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF0F2F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFC),
          primary: const Color(0xFF7C5CFC),
        ),
        useMaterial3: true,
      ),
      home: initialScreen,
    );
  }
}