enum DependentStatus { approved, rejected, pending }

class Dependent {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final DependentStatus status;

  Dependent({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.status,
  });

  factory Dependent.fromJson(Map<String, dynamic> json) {
    final String countryCode = json['country_code'] ?? '';
    final String phoneNumber = json['phone_number'] ?? '';
    return Dependent(
      id: json['pk'].toString(),
      fullName: '${json['first_name']} ${json['last_name']}',
      phone: '$countryCode$phoneNumber'.trim(),
      email: json['email'] ?? '',
      status: DependentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => DependentStatus.pending,
      ),
    );
  }
}
