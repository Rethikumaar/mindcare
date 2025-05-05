import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientDashboard extends StatefulWidget {
  final String userId;

  const PatientDashboard({Key? key, required this.userId}) : super(key: key);

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

  final List<Map<String, String>> poses = [
    {
      'name': 'Child\'s Pose',
      'image': 'assets/images/child_pose.png',
      'description': 'A resting pose that calms the mind and relieves tension.'
    },
    {
      'name': 'Downward Dog',
      'image': 'assets/images/downward_dog.png',
      'description': 'An energizing pose that stretches the entire body.'
    },
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
        String? selectedTime = _selectedTime;
        String? selectedDoctor = _selectedDoctor;

        return AlertDialog(
          title: Text("Schedule Appointment"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? "Choose a date"
                          : DateFormat('MMMM dd, yyyy').format(_selectedDate!),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text("Select Time", style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Select Time"),
                  value: selectedTime,
                  onChanged: (value) {
                    setState(() => _selectedTime = value);
                  },
                  items: _timeSlots.map((time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                ),
                SizedBox(height: 15),
                Text("Select Doctor", style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Select Doctor"),
                  value: selectedDoctor,
                  onChanged: (value) {
                    setState(() => _selectedDoctor = value);
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
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
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
              child: Text("Save Appointment"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedPoses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Featured Poses", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: poses.length,
            itemBuilder: (context, index) {
              final pose = poses[index];
              return Container(
                width: 140,
                margin: EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    Image.asset(pose['image']!, height: 80),
                    SizedBox(height: 5),
                    Text(pose['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(pose['description']!, style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyInspiration() {
    final index = DateTime.now().day % dailyInspirations.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Daily Inspiration", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text(dailyInspirations[index], style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Patient Profile"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Text("Welcome, ${user?.displayName ?? 'Patient'}", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _scheduleAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: Text("Schedule Appointment", style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 30),
            _buildFeaturedPoses(),
            SizedBox(height: 30),
            _buildDailyInspiration(),
          ],
        ),
      ),
    );
  }
}
