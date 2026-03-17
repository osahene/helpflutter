class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      profileImageUrl: json['profile_image'],
    );
  }
}
