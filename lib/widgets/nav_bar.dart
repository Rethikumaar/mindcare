import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final bool isLoggedIn;
  final String? userInitial;
  final Function()? onLogout;
  final Function(String)? onLoginSuccess;

  const NavBar({super.key, 
    required this.isLoggedIn,
    this.userInitial,
    this.onLogout,
    this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.health_and_safety, color: Colors.blue),
          SizedBox(width: 8),
          Text('MindCare', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        if (!isLoggedIn)
          TextButton(
            onPressed: () async {
              final name = await Navigator.pushNamed(context, '/login');
              if (name != null && onLoginSuccess != null) {
                onLoginSuccess!(name as String);
              }
            },
            child: const Text('Login', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        else
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Colors.purple,
              child: Text(userInitial ?? "", style: const TextStyle(color: Colors.white)),
            ),
            onSelected: (value) {
              if (value == 'logout' && onLogout != null) {
                onLogout!();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(value: 'profile', child: Text('Profile')),
                const PopupMenuItem(value: 'logout', child: Text('Logout', style: TextStyle(color: Colors.red))),
              ];
            },
          ),
        const SizedBox(width: 16),
      ],
    );
  }
}
