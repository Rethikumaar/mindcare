import 'package:flutter/material.dart';

class DoctorDashboard extends StatelessWidget {
  final String doctorName;

  const DoctorDashboard({super.key, required this.doctorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Dashboard')),
      body: Center(child: Text('Welcome, Dr. $doctorName')),
    );
  }
}
