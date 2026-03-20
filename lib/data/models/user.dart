class User {
  final String id;
  final String? firstName;
  final String? lastName;
  final String fullName;
  final String email;
  final String? countryCode;
  final String phone;
  final String? profileImageUrl;
  final String? token;

  User({
    required this.id,
    this.firstName,
    this.lastName,
    required this.fullName,
    required this.email,
    this.countryCode,
    required this.phone,
    this.profileImageUrl,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'],
      email: json['email'],
      countryCode: json['country_code'],
      phone: json['phone'],
      profileImageUrl: json['profile_image'],
      token: json['token'],
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'fullName': fullName,
    'phone': phone,
    'country_code': countryCode,
    'token': token,
  };
}
