enum ContactStatus { pending, approved, rejected }

class Contact {
  final String id;
  final String firstName;
  final String lastName;
  final String countryCode;
  final String phoneNumber;
  final String emailAddress;
  final String relation;
  final List<String> situation; // Keeps its internal Dart typing neat
  final ContactStatus status;

  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.countryCode,
    required this.phoneNumber,
    required this.emailAddress,
    required this.relation,
    required this.situation,
    required this.status,
  });

  // Adjust your toJson to map keys directly for the API pipeline
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'country_code': countryCode, // Aligned with Next.js & Django
      'phone_number': phoneNumber,
      'email_address': emailAddress,
      'relation': relation,
      'situations': situation, // Flattened array to match web payload
      'status': status.name,
    };
  }

  // Also adjust your fromJson to match incoming values safely
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      // Look for 'pk' from Django, fallback to 'id', fallback to empty string
      id: json['pk']?.toString() ?? json['id']?.toString() ?? '',

      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      countryCode: json['country_code'] ?? json['countryCode'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      emailAddress: json['email_address'] ?? '',
      relation: json['relation'] ?? '',
      situation: List<String>.from(json['situations'] ?? []),
      status: ContactStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ContactStatus.pending,
      ),
    );
  }
}
