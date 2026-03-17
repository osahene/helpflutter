enum ContactStatus { accepted, rejected, pending }

class Contact {
  final String id;
  final String firstName;
  final String lastName;
  final String address;
  final String phone;
  final String email;
  final String relation;
  final List<String> situations; // e.g., ['Robbery', 'Fire']
  final ContactStatus status;

  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.phone,
    required this.email,
    required this.relation,
    required this.situations,
    required this.status,
  });

  String get fullName => '$firstName $lastName';

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      relation: json['relation'],
      situations: List<String>.from(json['situations']),
      status: ContactStatus.values.firstWhere(
        (e) => e.toString() == 'ContactStatus.${json['status']}',
        orElse: () => ContactStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'phone': phone,
      'email': email,
      'relation': relation,
      'situations': situations,
    };
  }
}
