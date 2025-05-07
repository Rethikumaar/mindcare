import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientDashboard extends StatefulWidget {
  final String userId;

  const PatientDashboard({super.key, required this.userId});

  @override
  _PatientDashboardState createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedDoctor;

  final List<String> _timeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
  ];

  final List<String> _doctorList = [
    "Dr. Krishna",
    "Dr. Rethi",
    "Dr. Harsha",
    "Dr. Jackie",
    "Dr. Kartik"
  ];

  final List<String> dailyInspirations = [
    "Take a deep breath and let go of stress.",
    "Peace begins with a smile.",
    "You are stronger than you think.",
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _scheduleAppointment() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: const Text("Schedule Appointment"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? "Choose a date"
                            : DateFormat('MMMM dd, yyyy').format(_selectedDate!),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text("Select Time", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("Select Time"),
                    value: _selectedTime,
                    onChanged: (value) {
                      setStateDialog(() => _selectedTime = value);
                    },
                    items: _timeSlots.map((time) {
                      return DropdownMenuItem<String>(
                        value: time,
                        child: Text(time),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),
                  const Text("Select Doctor", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("Select Doctor"),
                    value: _selectedDoctor,
                    onChanged: (value) {
                      setStateDialog(() => _selectedDoctor = value);
                    },
                    items: _doctorList.map((doctor) {
                      return DropdownMenuItem<String>(
                        value: doctor,
                        child: Text(doctor),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (_selectedDate != null && _selectedTime != null && _selectedDoctor != null) {
                    await FirebaseFirestore.instance.collection('appointments').add({
                      'userId': widget.userId,
                      'userName': user?.displayName ?? 'Patient',
                      'date': _selectedDate,
                      'time': _selectedTime,
                      'doctor': _selectedDoctor,
                      'status': 'Scheduled',
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text("Save Appointment"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyInspiration() {
    final index = DateTime.now().day % dailyInspirations.length;
    return Card(
      color: Colors.deepPurple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Daily Inspiration", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(dailyInspirations[index], style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Dashboard"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text("Welcome, ${user?.displayName ?? 'Patient'}", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _scheduleAppointment,
              icon: const Icon(Icons.schedule),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              label: const Text("Schedule Appointment", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 30),
            _buildDailyInspiration(),
          ],
        ),
      ),
    );
  }
}
