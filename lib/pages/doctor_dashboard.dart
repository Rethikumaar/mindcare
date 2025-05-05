import 'package:flutter/material.dart';

class DoctorDashboard extends StatelessWidget {
  final String doctorName;

  const DoctorDashboard({Key? key, required this.doctorName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Doctor Dashboard')),
      body: Center(child: Text('Welcome, Dr. $doctorName')),
    );
  }
}
