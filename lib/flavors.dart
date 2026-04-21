enum Flavor { dev, uat, prod }

class F {
  static Flavor? _appFlavor;

  static Flavor get appFlavor => _appFlavor ?? Flavor.dev;

  static set appFlavor(Flavor value) {
    _appFlavor = value;
  }

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'YoloApp Dev';
      case Flavor.uat:
        return 'YoloApp UAT';
      case Flavor.prod:
        return 'YoloApp';
    }
  }
}
