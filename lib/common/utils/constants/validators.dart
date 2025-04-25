/// A collection of validation functions for forms in the app.
class Validators {
  Validators._() {
    //print('Validators initialized');
  }

  /// Validates an email address.
  /// Returns an error message if invalid, or null if valid.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Regular expression for email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  /// Validates a password.
  /// Returns an error message if invalid, or null if valid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validates a name.
  /// Returns an error message if invalid, or null if valid.
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  /// Validates a roll number.
  /// Returns an error message if invalid, or null if valid.
  static String? validateRollNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Roll number is required';
    }

    // Can add additional roll number format validation if needed

    return null;
  }

  /// Validates a class degree.
  /// Returns an error message if invalid, or null if valid.
  static String? validateDegree(String? value) {
    if (value == null || value.isEmpty) {
      return 'Degree is required';
    }

    return null;
  }

  /// Validates a class year.
  /// Returns an error message if invalid, or null if valid.
  static String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Year is required';
    }

    int? year = int.tryParse(value);
    if (year == null) {
      return 'Year must be a number';
    }

    if (year < 1 || year > 6) {
      return 'Year must be between 1 and 6';
    }

    return null;
  }

  /// Validates a subject.
  /// Returns an error message if invalid, or null if valid.
  static String? validateSubject(String? value) {
    if (value == null || value.isEmpty) {
      return 'Subject is required';
    }

    return null;
  }

  /// Validates a phone number.
  /// Returns an error message if invalid, or null if valid.
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }

    // Simple validation - can be customized for specific country formats
    if (value.length < 10) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  /// Validates required field.
  /// Returns an error message if empty, or null if valid.
  static String? validateRequired(String? value,
      {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }
}
