class Validators {
  static const allowedDomain = '@alustudent.com';

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final e = value.trim().toLowerCase();
    if (!e.endsWith(allowedDomain) || e.length <= allowedDomain.length) {
      return 'Use your ALU student email ($allowedDomain)';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'At least 8 characters';
    return null;
  }

  static String? required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }
}
