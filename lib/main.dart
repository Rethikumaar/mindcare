import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mindcare/pages/phq9_result_page.dart';
import 'firebase_options.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/phq9_questionnaire.dart';
import 'widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF4F7FE),
      ),
      home: const MainScreen(), // Set the main screen
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/assessment': (context) =>  PHQ9Questionnaire(),
      },
    );
  }
}


