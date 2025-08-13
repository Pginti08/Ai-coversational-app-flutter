enum FlavorType { development, demo, staging, production }

class Flavor {
  /// Represents the active Environment.
  static late FlavorType setFlavor;

  static FlavorType get getFlavor {
    return setFlavor;
  }
}
