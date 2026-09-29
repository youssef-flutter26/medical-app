import 'package:easy_localization/easy_localization.dart';
import 'package:medical_app/core/localization/locale_keys.dart';

abstract final class ValidatorApp {
  ValidatorApp._();

  static final RegExp birthDateRegex = RegExp(
    r'^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$',
  );
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$",
  );

  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d@]{6,}$',
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

  static String? validateBirthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.dateOfBirth.tr();
    }

    final birthDate = value.trim();

    if (!birthDateRegex.hasMatch(birthDate)) {
      return LocaleKeys.dateOfBirth.tr();
    }

    return null;
  }

  static String? validateGender(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.gender.tr();
    }
    return null;
  }

  static String? validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.nickname.tr();
    }
    return null;
  }

  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.titleCannotBeEmpty.tr();
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.descriptionCannotBeEmpty.tr();
    }
    return null;
  }

  static String? validateImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.imageUrlCannotBeEmpty.tr();
    }
    return null;
  }

  static String? validateImageName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.imageNameCannotBeEmpty.tr();
    }
    return null;
  }

  static String? validateMedicalCenterName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.nameCannotBeEmpty.tr();
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.addressCannotBeEmpty.tr();
    }
    return null;
  }

  static String? validateRating(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.ratingCannotBeEmpty.tr();
    }
    final rating = double.tryParse(value.trim());
    if (rating == null || rating < 0.0 || rating > 5.0) {
      return LocaleKeys.invalidRating.tr();
    }
    return null;
  }

  static String? validateReviewsCount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.reviewsCountCannotBeEmpty.tr();
    }
    final count = int.tryParse(value.trim());
    if (count == null || count < 0) {
      return LocaleKeys.invalidReviewsCount.tr();
    }
    return null;
  }

  static String? validateDistance(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.distanceCannotBeEmpty.tr();
    }
    final clean = value.replaceAll(RegExp(r'[^\d.]'), '').trim();
    final distance = double.tryParse(clean);
    if (distance == null || distance < 0) {
      return LocaleKeys.invalidDistance.tr();
    }
    return null;
  }

  static String? validateDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.durationCannotBeEmpty.tr();
    }
    final clean = value.replaceAll(RegExp(r'[^\d]'), '').trim();
    final duration = int.tryParse(clean);
    if (duration == null || duration < 0) {
      return LocaleKeys.invalidDuration.tr();
    }
    return null;
  }
}


