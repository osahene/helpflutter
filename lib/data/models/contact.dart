class Contact {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String relation;
  final String status; // pending, approved, rejected

  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.relation,
    required this.status,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['pk'].toString(),
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email_address'] ?? '',
      phoneNumber: json['full_phone_number'] ?? json['phone_number'],
      relation: json['relation'],
      status: json['status'],
    );
  }
}
