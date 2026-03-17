class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone is required';
    // You can add more specific validation
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) return 'Address is required';
    return null;
  }

  static String? validateRelation(String? value) {
    if (value == null || value.isEmpty) return 'Relation is required';
    return null;
  }

  static String? validateSituations(List<String>? value) {
    if (value == null || value.isEmpty) return 'Select at least one situation';
    return null;
  }
}
