bool isNullOrEmpty(dynamic val) {
  final value = val.toString();
  return val == null ||
      value.isEmpty ||
      value == 'null' ||
      value == '' ||
      value == 'NULL' ||
      value == '{}';
}

bool isNotNullOrEmpty(dynamic val) {
  final value = val.toString();
  return !(val == null ||
      value.isEmpty ||
      value == 'null' ||
      value == '' ||
      value == 'NULL' ||
      value == '{}');
}

bool isUrl(String? input) {
  // Regular expression pattern to match URLs
  final urlRegExp = RegExp(r'^(?:http|https):\/\/[^\s]+');

  return isNullOrEmpty(input) ? false : urlRegExp.hasMatch(input!);
}

String formatTime(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

String formatNumber(double number) {
  // Convert the number to a string with two decimal places
  String formatted = number.toStringAsFixed(2);

  // Check if the formatted number ends with ".00" or ".0"
  if (formatted.endsWith(".00")) {
    // Remove the ".00"
    return formatted.split(".")[0];
  } else if (formatted.endsWith(".0")) {
    // Remove the ".0"
    return formatted.split(".")[0];
  }

  return formatted;
}

String removeEmojis(String input) {
  return input.replaceAll(RegExp(r'[^\w\s]'), '').trim();
}

String maskEmail(String email) {
  if (!email.contains('@')) return email;

  final parts = email.split('@');
  final name = parts[0];
  final domain = parts[1];

  if (name.length <= 1) {
    return '${name[0]}*****@$domain';
  }

  final masked = name[0] + '*' * (name.length - 2) + name[name.length - 1];
  return '$masked@$domain';
}

DateTime parseUtcToLocal(String utcString) {
  // Add 'Z' to mark it as UTC
  final utcWithZ = '${utcString}Z';

  // Parse as UTC DateTime
  final utcDateTime = DateTime.parse(utcWithZ);

  // Convert to local
  return utcDateTime.toLocal();
}

final Map<String, Map<String, String>> allyroidRegisterQuestion = {
  "1": {
    "title": "Cognition",
    "question": "Will your Allyroid think logically or creatively?",
    "option1": "🧠 Rational",
    "option2": "🎨 Intuitive"
  },
  "2": {
    "title": "Energy/Focus",
    "question": "Will your Allyroid thrive outwardly or inwardly?",
    "option1": "🌟 Extraverted",
    "option2": "🧘 Introverted"
  },
  "3": {
    "title": "Interaction Style",
    "question": "Will your Allyroid lead or collaborate?",
    "option1": "🎯 Directive",
    "option2": "🤝 Collaborative"
  },
  "4": {
    "title": "Task Approach",
    "question": "Will your Allyroid prefer structure or adaptability?",
    "option1": "📋 Structured",
    "option2": "🌊 Flexible"
  },
  "5": {
    "title": "Tone",
    "question": "Will your Allyroid sound formal or casual?",
    "option1": "🎩 Formal",
    "option2": "👕 Casual"
  },
  "6": {
    "title": "Worldview",
    "question": "Will your Allyroid see possibilities or practicalities?",
    "option1": "🌈 Optimistic",
    "option2": "🌱 Realistic"
  },
  "7": {
    "title": "Emotional Sensitivity",
    "question": "Will your Allyroid stay neutral or connect emotionally?",
    "option1": "🎛️ Neutral",
    "option2": "❤️ Empathetic"
  },
  "8": {
    "title": "Decision-Making",
    "question": "Will your Allyroid act fast or think it through?",
    "option1": "⚡ Quick",
    "option2": "🕰️ Deliberative"
  },
  "9": {
    "title": "Scope",
    "question": "Will your Allyroid focus on details or the big picture?",
    "option1": "🔍 Detail-Oriented",
    "option2": "🌐 Big-Picture"
  },
  "10": {
    "title": "Communication",
    "question": "Will your Allyroid inform or motivate?",
    "option1": "🎩 Informative",
    "option2": "🔥 Persuasive"
  }
};
