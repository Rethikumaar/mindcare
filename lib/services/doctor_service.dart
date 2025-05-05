import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor.dart';

class DoctorService {
  final CollectionReference _doctorCollection =
  FirebaseFirestore.instance.collection('doctors');

  Future<List<Doctor>> fetchDoctors() async {
    final snapshot = await _doctorCollection.get();
    return snapshot.docs
        .map((doc) => Doctor.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
