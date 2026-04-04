enum ContactStatus { approved, rejected, pending }

class Contact {
  final String id;
  final String firstName;
  final String lastName;
  final String? fullName;
  final String email;
  final String phoneNumber;
  final String relation;
  final Map<String, dynamic>? situation;
  final ContactStatus status;

  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.relation,
    this.situation,
    required this.status,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['pk'].toString(),
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: '${json['first_name']} ${json['last_name']}',
      email: json['email_address'] ?? '',
      phoneNumber: json['full_phone_number'] ?? json['phone_number'],
      relation: json['relation'],
      status: ContactStatus.values.firstWhere(
        (s) => s.toString() == json['status'],
      ),
      situation: json['situation'] as Map<String, dynamic>?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'pk': id,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'email_address': email,
      'phone_number': phoneNumber,
      'relation': relation,
      'situation': situation,
      'status': status,
    };
  }
}
