import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController passwordController = TextEditingController();
  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      print("login Successfull");
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Error: ${e.toString()}')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log in', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            Text('Before we start, please log into your account'),
            SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email', hintText: 'Enter your email...'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password', hintText: 'Enter your password...'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding: EdgeInsets.symmetric(vertical: 16),
                elevation: 6,
              ),
              onPressed:_login,
              child: Center(
                child: Text('Log in', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  children: [
                    TextSpan(text: "Sign up", style: TextStyle(color: Colors.purpleAccent)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

