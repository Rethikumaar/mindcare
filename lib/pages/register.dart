import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String role = "Doctor";

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _register() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        String displayName = '${firstNameController.text.trim()} ${lastNameController.text.trim()}';
        await user.updateDisplayName(displayName);
        await user.reload();
        user = _auth.currentUser;

        await _firestore.collection('users').doc(user!.uid).set({
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
          'email': emailController.text.trim(),
          'username': usernameController.text.trim(),
          'role': role.toLowerCase(),
          'uid': user.uid,
        });

        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Error: ${e.toString()}')),
      );
    }
  }

  Widget _buildField(String label, {bool isPassword = false, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(hintText: 'Enter a $label...'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Register', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              const Text('Before we start, please create your account'),
              const SizedBox(height: 20),
              _buildField('First name', controller: firstNameController),
              _buildField('Last name', controller: lastNameController),
              _buildField('Email', controller: emailController),
              _buildField('Username', controller: usernameController),
              _buildField('Password', controller: passwordController, isPassword: true),
              const SizedBox(height: 10),
              const Text('Role'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: role == 'Doctor' ? Colors.purpleAccent : Colors.grey.shade200,
                      ),
                      onPressed: () => setState(() => role = "Doctor"),
                      child: Text("Doctor", style: TextStyle(color: role == 'Doctor' ? Colors.white : Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: role == 'Patient' ? Colors.purpleAccent : Colors.grey.shade200,
                      ),
                      onPressed: () => setState(() => role = "Patient"),
                      child: Text("Patient", style: TextStyle(color: role == 'Patient' ? Colors.white : Colors.black)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 6,
                ),
                onPressed: _register,
                child: const Center(
                  child: Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
