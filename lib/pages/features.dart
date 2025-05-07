import 'package:flutter/material.dart';
import '../../pages/patient_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeaturesScreen extends StatefulWidget {
  final String? userName;
  final String? userId;
  final Function(String, String)? onLoginSuccess;
  final Function()? onLogout;

  const FeaturesScreen({
    super.key,
    this.userName,
    this.userId,
    this.onLoginSuccess,
    this.onLogout,
  });

  @override
  _FeaturesScreenState createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends State<FeaturesScreen> {
  final GlobalKey _profileButtonKey = GlobalKey();

  final List<Map<String, String>> features = [
    {
      'title': 'Smart Assessments',
      'desc': 'Conduct AI-based mental health assessments with ease.',
    },
    {
      'title': 'Secure Records',
      'desc': 'Manage patient history securely on the cloud.',
    },
    {
      'title': 'Virtual Appointments',
      'desc': 'Schedule and conduct online therapy sessions.',
    },
  ];

  void _logout() {
    FirebaseAuth.instance.signOut().then((_) {
      if (widget.onLogout != null) {
        widget.onLogout!();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully logged out')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $error')),
      );
    });
  }

  void _showProfileDropdown() {
    final RenderBox renderBox = _profileButtonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + renderBox.size.height,
        position.dx + renderBox.size.width,
        position.dy + renderBox.size.height + 100,
      ),
      items: [
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.person, color: Colors.blue),
              SizedBox(width: 8),
              Text('View Profile'),
            ],
          ),
          onTap: () {
            // Using Future.delayed because onTap dismisses the menu before navigation
            Future.delayed(Duration.zero, () {
              if (widget.userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientDashboard(userId: widget.userId!),
                  ),
                );
              }
            });
          },
        ),
        PopupMenuItem(
          onTap: _logout,
          child: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          "Features",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.userName == null)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            InkWell(
              key: _profileButtonKey,
              onTap: _showProfileDropdown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 18,
                  child: Text(
                    widget.userName![0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final item = features[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                item['title']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  item['desc']!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}