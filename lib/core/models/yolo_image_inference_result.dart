import 'dart:typed_data';

import 'package:ultralytics_yolo/ultralytics_yolo.dart';

/// Parsed result returned by the single-image inference service.
class YoloImageInferenceResult {
  const YoloImageInferenceResult({
    required this.originalImage,
    required this.detections,
    this.annotatedImage,
  });

  final Uint8List originalImage;
  final Uint8List? annotatedImage;
  final List<YOLOResult> detections;
}
