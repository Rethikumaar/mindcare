import 'package:flutter/material.dart';
import '../../pages/patient_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PricingScreen extends StatefulWidget {
  final String? userName;
  final String? userId;
  final Function(String, String)? onLoginSuccess;
  final Function()? onLogout;

  const PricingScreen({
    super.key,
    this.userName,
    this.userId,
    this.onLoginSuccess,
    this.onLogout,
  });

  @override
  _PricingScreenState createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final GlobalKey _profileButtonKey = GlobalKey();

  final List<Map<String, dynamic>> plans = [
    {
      'title': 'Basic Plan',
      'price': '\$19/month',
      'desc': 'Essential features for small practices.',
      'features': [
        'Patient records',
        'Basic appointment scheduling',
        'Email support'
      ]
    },
    {
      'title': 'Pro Plan',
      'price': '\$49/month',
      'desc': 'Advanced tools and analytics.',
      'features': [
        'Everything in Basic',
        'Custom assessments',
        'Analytics dashboard',
        'Priority support'
      ]
    },
    {
      'title': 'Enterprise',
      'price': 'Contact Us',
      'desc': 'Custom solutions for large organizations.',
      'features': [
        'Everything in Pro',
        'Custom integrations',
        'Dedicated support',
        'Team management'
      ]
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
                    builder: (context) => PatientProfilePage(userId: widget.userId!),
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
          "Pricing",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      plan['title']!,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  Text(
                      plan['price']!,
                      style: const TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.w500)
                  ),
                  const SizedBox(height: 8),
                  Text(plan['desc']!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ...List.generate(
                    plan['features'].length,
                        (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(plan['features'][i], style: const TextStyle(fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      onPressed: () {
                        // Handle subscription
                      },
                      child: const Text('Select Plan', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}