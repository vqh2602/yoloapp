import 'dart:typed_data';

import 'package:ultralytics_yolo/ultralytics_yolo.dart';

/// Kết quả đã phân tích được trả về bởi dịch vụ suy luận hình ảnh đơn lẻ.
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
