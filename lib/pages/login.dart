import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
              onPressed: () {
                final name = emailController.text.split('@').first;
                Navigator.pop(context, name); // return user name
              },
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
