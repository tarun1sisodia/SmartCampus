/// TValidator: Robust validation utility for form inputs and data verification
class TValidator {
  TValidator._()
  {
    //printnt('TValidator initialized');
  } // Private constructor to prevent instantiation
  /// Validate email address
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    
    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address';
    }
    
    return null;
  }

  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    // Check for minimum password length
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    // Check for password strength
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validate phone number
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Regular expression for phone number validation
    final phoneRegExp = RegExp(r'^\d{10}$');
    
    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid phone number format (10 digits required)';
    }

    return null;
  }

  /// Validate name
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    // Regular expression for name validation (letters and spaces only)
    final nameRegExp = RegExp(r'^[a-zA-Z ]+$');
    
    if (!nameRegExp.hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  /// Validate price
  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    if (double.tryParse(value) == null) {
      return 'Price must be a valid number';
    }

    if (double.parse(value) <= 0) {
      return 'Price must be greater than zero';
    }

    return null;
  }

  /// Validate quantity
  static String? quantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }

    if (int.tryParse(value) == null) {
      return 'Quantity must be a valid number';
    }

    if (int.parse(value) < 0) {
      return 'Quantity cannot be negative';
    }

    return null;
  }

  /// Validate card number
  static String? cardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }

    // Remove any spaces or dashes
    final cleanNumber = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if it contains only digits and has valid length
    if (!RegExp(r'^\d{16}$').hasMatch(cleanNumber)) {
      return 'Invalid card number';
    }

    return null;
  }

  /// Validate CVV
  static String? cvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }

    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'Invalid CVV';
    }

    return null;
  }

  /// Validate date
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    // Regular expression for date format MM/YY
    final dateRegExp = RegExp(r'^\d{2}/\d{2}$');
    
    if (!dateRegExp.hasMatch(value)) {
      return 'Invalid date format (MM/YY)';
    }

    return null;
  }

  /// Validate postal code
  static String? postalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }

    // Regular expression for postal code (customize based on your country format)
    final postalRegExp = RegExp(r'^\d{6}$');
    
    if (!postalRegExp.hasMatch(value)) {
      return 'Invalid postal code';
    }

    return null;
  }
}
