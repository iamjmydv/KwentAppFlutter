import 'package:kwentappflutter/core/resources/strings.dart';

class Validators {
  const Validators._();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return Strings.emailRequired;
    if (!_emailPattern.hasMatch(input)) return Strings.emailInvalid;
    return null;
  }

  static String? password(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return Strings.passwordRequired;
    if (input.length < 8) return Strings.passwordTooShort;
    return null;
  }

  static String? notEmpty(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }
}
