import 'contact.dart';

class Dependent {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final ContactStatus status; // pending, accepted, rejected

  Dependent({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.status,
  });

  factory Dependent.fromJson(Map<String, dynamic> json) {
    return Dependent(
      id: json['id'],
      fullName: json['full_name'],
      phone: json['phone'],
      email: json['email'],
      status: ContactStatus.values.firstWhere(
        (e) => e.toString() == 'ContactStatus.${json['status']}',
        orElse: () => ContactStatus.pending,
      ),
    );
  }
}
