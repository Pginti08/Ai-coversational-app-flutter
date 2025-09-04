String? validateCommonField(String? value, String filedName) {
  if (value == null || value.isEmpty) {
    return 'Please enter $filedName';
  }
  return null;
}

String? validateMeasurementField(String? value, String filedName) {
  if (value == null || value.isEmpty) {
    return 'Please enter $filedName size';
  } else if (int.tryParse(value.toString()) == 0) {
    return 'Please enter valid $filedName size';
  }
  return null;
}

String? validateEmail(String? value) {
  final emailRegex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');
  if (value == null || value.isEmpty) {
    return 'Please enter email';
  } else if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}

String? validateMobileNumber(String? value, int minLength, int maxLength) {
  if (value == null || value.isEmpty) {
    return 'Please enter mobile number';
  }

  if (value.length < minLength || value.length > maxLength) {
    return 'Please enter valid mobile number';
  }

  return null;
}

String? validatePincode(String? value, int minLength, int maxLength) {
  if (value == null || value.isEmpty) {
    return 'Please enter pincode';
  }

  if (value.length < minLength || value.length > maxLength) {
    return 'Please enter valid pincode';
  }

  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter password';
  }

  if (value.length < 8 || value.length > 20) {
    return 'Password must be between 8 and 20 characters';
  }

  final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
  final hasNumber = RegExp(r'\d').hasMatch(value);
  final hasSpecial = RegExp(r'[!@#\$&*~]').hasMatch(value);

  if (!hasLetter || !hasNumber || !hasSpecial) {
    return 'Password must include at least one letter, one number, and one special character';
  }

  return null;
}

String? validateOTP(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter OTP';
  }

  if (value.length < 6) {
    return 'Please enter valid OTP';
  }

  return null;
}

String? validateConfirmPassword(String? value, String? originalPassword) {
  if (value == null || value.isEmpty) {
    return 'Please enter password';
  }

  if (value.length < 8 || value.length > 20) {
    return 'Password must be between 8 and 20 characters';
  }

  final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
  final hasNumber = RegExp(r'\d').hasMatch(value);
  final hasSpecial = RegExp(r'[!@#\$&*~]').hasMatch(value);

  if (!hasLetter || !hasNumber || !hasSpecial) {
    return 'Password must include at least one letter, one number, and one special character';
  }

  if (value.trim() != originalPassword) {
    return 'Passwords do not match';
  }

  return null;
}
