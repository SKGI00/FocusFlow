/// User-entered focus duration. Presets are 15, 30 and 60 minutes.
class FocusDuration {
  static const int minimum = 3;
  static const int maximum = 120;

  static int? parse(String input) {
    final minutes = int.tryParse(input.trim());
    if (minutes == null || minutes < minimum || minutes > maximum) {
      return null;
    }
    return minutes;
  }
}
