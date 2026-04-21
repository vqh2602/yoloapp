abstract final class AppConstants {
  static const double defaultConfidenceThreshold = 0.25;
  static const double defaultIoUThreshold = 0.70;
  static const int defaultNumItemsThreshold = 30;
  static const List<String> supportedModelExtensions = <String>[
    'tflite',
    'mlmodel',
    'mlpackage',
    'zip',
  ];
}
