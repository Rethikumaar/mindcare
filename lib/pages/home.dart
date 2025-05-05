import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/nav_bar.dart';
import 'patient_profile_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? firebaseUser;
  String? userRole;

  @override
  void initState() {
    super.initState();
    firebaseUser = FirebaseAuth.instance.currentUser;
  }

  void handleLogout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      firebaseUser = null;
      userRole = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = firebaseUser != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: NavBar(
          isLoggedIn: isLoggedIn,
          userInitial:
          isLoggedIn ? firebaseUser!.email![0].toUpperCase() : null,
          onLogout: handleLogout,
          onLoginSuccess: (_) {
            setState(() {
              firebaseUser = FirebaseAuth.instance.currentUser;
              userRole = 'patient';
            });
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Transform Mental Healthcare\nManagement',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Streamline your mental health practice with our comprehensive platform.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    onPressed: () {
                      if (!isLoggedIn) {
                        Navigator.pushNamed(context, '/register');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>PatientDashboard(
                              userId: firebaseUser!.uid,
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Text(
                          !isLoggedIn ? 'Get Started' : 'View Profile',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.arrow_right_alt),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      side: const BorderSide(color: Colors.black),
                    ),
                    onPressed: () {
                      if (!isLoggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please log in to take the assessment'),
                          ),
                        );
                      } else {
                        Navigator.pushNamed(context, '/assessment');
                      }
                    },
                    child: const Text(
                      'Take Assessment',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
