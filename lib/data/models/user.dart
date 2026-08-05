class User {
  final String id;
  final String? firstName;
  final String? lastName;
  final String fullName;
  final String? countryCode;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool? isVerified;

  User({
    required this.id,
    this.firstName,
    this.lastName,
    required this.fullName,
    this.countryCode,
    this.phoneNumber,
    this.profileImageUrl,
    this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: '${json['first_name']} ${json['last_name']}',
      countryCode: json['country_code'],
      phoneNumber: json['phone'],
      profileImageUrl: json['profile_image_url'],
      isVerified: json['is_verified'],
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'fullName': fullName,
    'country_code': countryCode,
  };
}
