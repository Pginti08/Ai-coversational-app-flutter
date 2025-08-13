String? validateCommonField(String? value, String filedName) {
  if (value == null || value.isEmpty) {
    return 'Please enter $filedName';
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

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter password';
  }

  if (value.length < 8 || value.length > 20) {
    return 'Password must be between 8 and 20 characters';
  }

  final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
  final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
  final hasNumber = RegExp(r'\d').hasMatch(value);
  final hasSpecial = RegExp(r'[!@#\$&*~]').hasMatch(value);

  if (!hasLetter || !hasNumber || !hasSpecial || !hasUppercase) {
    return 'Password must include at least one uppercase letter, one lowercase letter, one number, and one special character';
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
