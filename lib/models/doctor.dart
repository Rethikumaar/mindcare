class Doctor {
  final String id;
  final String name;

  Doctor({required this.id, required this.name});

  factory Doctor.fromMap(Map<String, dynamic> data, String documentId) {
    return Doctor(
      id: documentId,
      name: data['name'] ?? '',
    );
  }
}
