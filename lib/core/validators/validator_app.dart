import 'package:easy_localization/easy_localization.dart';
import 'package:medical_app/core/localization/locale_keys.dart';

abstract final class ValidatorApp {
  ValidatorApp._();

  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$",
  );

  static final RegExp _passwordRegex = RegExp(
    r'^\S{8,}$',
  );

  static final RegExp _phoneRegex = RegExp(r'^\+?\d{10,15}$');

  static final RegExp _codeRegex = RegExp(r'^\d{6}$');

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.emailCannotBeEmpty.tr();
    }

    final email = value.trim();

    if (!_emailRegex.hasMatch(email)) {
      return LocaleKeys.enterValidEmail.tr();
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.passwordCannotBeEmpty.tr();
    }

    if (!_passwordRegex.hasMatch(value)) {
      return LocaleKeys.passwordRequirements.tr();
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.confirmPasswordCannotBeEmpty.tr();
    }

    if (value != password) {
      return LocaleKeys.confirmPasswordMustMatch.tr();
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.nameCannotBeEmpty.tr();
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.phoneNumberCannotBeEmpty.tr();
    }

    final phone = value.trim();

    if (!_phoneRegex.hasMatch(phone)) {
      return LocaleKeys.enterValidPhoneNumber.tr();
    }

    return null;
  }

  static String? validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.codeCannotBeEmpty.tr();
    }

    final code = value.trim();

    if (!_codeRegex.hasMatch(code)) {
      return LocaleKeys.codeMustBeSixDigits.tr();
    }

    return null;
  }
}
