import 'package:flutter/material.dart';
import '../../pages/patient_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PricingScreen extends StatefulWidget {
  final String? userName;
  final String? userId;
  final Function(String, String)? onLoginSuccess;
  final Function()? onLogout;

  const PricingScreen({
    Key? key,
    this.userName,
    this.userId,
    this.onLoginSuccess,
    this.onLogout,
  }) : super(key: key);

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
        SnackBar(content: Text('Successfully logged out')),
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
          child: Row(
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
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          onTap: _logout,
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
        title: Text(
          "Pricing",
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
              child: Text(
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
                    style: TextStyle(
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
        padding: EdgeInsets.all(16),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Card(
            margin: EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      plan['title']!,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  SizedBox(height: 8),
                  Text(
                      plan['price']!,
                      style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.w500)
                  ),
                  SizedBox(height: 8),
                  Text(plan['desc']!, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 16),
                  ...List.generate(
                    plan['features'].length,
                        (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(plan['features'][i], style: TextStyle(fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      onPressed: () {
                        // Handle subscription
                      },
                      child: Text('Select Plan', style: TextStyle(fontSize: 16)),
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