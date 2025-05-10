import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientProfilePage extends StatefulWidget {
  final String userId;
  const PatientProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedDoctor;
  String? _appointmentId;

  Map<String, dynamic>? _nextAppointment;
  final List<String> _timeSlots = [
    '09:00 AM', '10:30 AM', '11:00 AM', '02:00 PM', '04:00 PM'
  ];
  final List<String> _doctorList = [
    "Dr. Krishna", "Dr. Rethi", "Dr. Harsha", "Dr. Jackie", "Dr. Kartik"
  ];
  final List<String> dailyInspirations = [
    "Take a deep breath and let go of stress.",
    "Peace begins with a smile.",
    "You are stronger than you think.",
  ];

  @override
  void initState() {
    super.initState();
    _loadNextAppointment();
  }

  Future<void> _loadNextAppointment() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: widget.userId)
        .where('status', isEqualTo: 'Scheduled')
        .orderBy('date')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _nextAppointment = snapshot.docs.first.data();
        _appointmentId = snapshot.docs.first.id;
      });
    } else {
      setState(() {
        _nextAppointment = null;
        _appointmentId = null;
      });
    }
  }

  Future<void> _cancelAppointment() async {
    if (_appointmentId != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel Appointment'),
          content: const Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('appointments')
                    .doc(_appointmentId)
                    .update({'status': 'Cancelled'});

                Navigator.pop(context);
                _loadNextAppointment();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment cancelled successfully')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
      );
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
                    onTap: () async {
                      DateTime initial = DateTime.now().add(const Duration(days: 1));
                      // Ensure initial date is a weekday
                      while (initial.weekday >= 6) {
                        initial = initial.add(const Duration(days: 1));
                      }

                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? initial,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                        selectableDayPredicate: (DateTime date) {
                          return date.weekday < 6 &&
                              date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
                        },
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          _selectedDate = picked;
                        });
                      }
                    }
                    ,
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

                    setState(() {
                      _selectedDate = null;
                      _selectedTime = null;
                      _selectedDoctor = null;
                    });

                    _loadNextAppointment();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Appointment scheduled successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all appointment details')),
                    );
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

  Widget _buildCard(String title, String content, {String? subtitle}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(content, style: const TextStyle(fontSize: 16)),
            if (subtitle != null)
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
      ),
      icon: Icon(icon),
      onPressed: onPressed,
      label: Text(text),
    );
  }

  Widget _buildNextAppointmentCard() {
    if (_nextAppointment == null) {
      return _buildCard("Next Appointment", "No appointment scheduled");
    }

    final date = (_nextAppointment!['date'] as Timestamp).toDate();
    final formattedDate = DateFormat('dd MMMM yyyy').format(date);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Next Appointment", style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _cancelAppointment,
                  child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "$formattedDate\n${_nextAppointment!['time']} with ${_nextAppointment!['doctor']}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyInspiration() {
    final index = DateTime.now().day % dailyInspirations.length;
    return _buildCard("Daily Inspiration", "\"${dailyInspirations[index]}\"", subtitle: "― MindCare");
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('MindCare', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          )
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Welcome,\n${user?.displayName ?? 'Patient'}",
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildNextAppointmentCard(),
            _buildCard("Prescriptions", "3", subtitle: "1 needs refill"),
            _buildCard("Lab Results", "2", subtitle: "1 new result"),
            _buildCard("Messages", "5", subtitle: "2 unread"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _scheduleAppointment,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("Schedule New Appointment"),
            ),
            const SizedBox(height: 20),
            const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildQuickActionButton("Book AI Call", Icons.chat, () {}),
                _buildQuickActionButton("Request Refill", Icons.medication, () {}),
                _buildQuickActionButton("View Test Result", Icons.article, () {}),
                _buildQuickActionButton("Manage Appointment", Icons.calendar_today, _scheduleAppointment),
              ],
            ),
            const SizedBox(height: 20),
            _buildDailyInspiration(),
          ],
        ),
      ),
    );
  }
}
