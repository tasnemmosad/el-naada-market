import 'dart:convert';

abstract final class AuthValidators {
  static final RegExp _phoneRegex = RegExp(r'^01[0125][0-9]{8}$');

  static String? phone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'يرجى إدخال رقم الموبايل';
    }

    if (!_phoneRegex.hasMatch(phone)) {
      return 'يرجى إدخال رقم موبايل مصري صحيح';
    }

    return null;
  }

  static String? password(String? value, {bool isRegister = false}) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }

    if (isRegister) {
      if (value.length < 8) {
        return 'كلمة المرور يجب ألا تقل عن 8 أحرف';
      }

      if (utf8.encode(value).length > 72) {
        return 'كلمة المرور طويلة جدًا';
      }
    }

    return null;
  }

  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }

    if (value != originalPassword) {
      return 'كلمتا المرور غير متطابقتين';
    }

    return null;
  }
}
