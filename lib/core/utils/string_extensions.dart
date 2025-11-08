extension StringExtensions on String {
  /// Capitalizes the first letter of the string
  String capitalize() {
    if (isEmpty) return this;
    if (length == 1) return toUpperCase();
    return this[0].toUpperCase() + substring(1);
  }

  /// Validates if the string is a valid email format
  bool isValidEmail() {
    if (isEmpty) return false;
    // Email regex that disallows dots at start/end of local part
    // Allows 1 char (alphanumeric only) or 2+ chars (alphanumeric at start/end, special chars in middle)
    final emailRegex = RegExp(
      r'^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9._%+-]*[a-zA-Z0-9])@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Checks if the string contains only numeric characters
  bool isNumeric() {
    if (isEmpty) return false;
    return RegExp(r'^\d+$').hasMatch(this);
  }

  /// Converts a string to a list of words (split by whitespace)
  List<String> toWordList() {
    return trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
  }

  /// Removes all whitespace from the string
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Checks if the string is a palindrome
  bool isPalindrome() {
    final cleaned = toLowerCase().removeWhitespace();
    if (cleaned.isEmpty) return false;
    return cleaned == cleaned.split('').reversed.join();
  }

  /// Counts the number of words in the string
  int wordCount() {
    return toWordList().length;
  }

  /// Truncates the string to a maximum length with an optional suffix
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return substring(0, maxLength - suffix.length) + suffix;
  }

  /// Converts the string to title case (capitalizes first letter of each word)
  String toTitleCase() {
    return toWordList().map((word) => word.capitalize()).join(' ');
  }

  /// Checks if the string contains only alphabetic characters
  bool isAlpha() {
    if (isEmpty) return false;
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// Checks if the string contains only alphanumeric characters
  bool isAlphanumeric() {
    if (isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  /// Reverses the string
  String reverse() {
    return split('').reversed.join();
  }
}
