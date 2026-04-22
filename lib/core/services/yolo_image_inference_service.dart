import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:yoloapp/core/models/yolo_image_inference_result.dart';
import 'package:yoloapp/core/models/yolo_model_descriptor.dart';

/// Xử lý suy luận hình ảnh đơn lẻ và duy trì một thực thể YOLO có thể tái sử dụng.
///
/// Dịch vụ chỉ tạo lại model gốc khi đường dẫn model, task hoặc cài đặt GPU
/// thay đổi. Điều này giúp mã UI nhỏ gọn và tránh việc khởi tạo trùng lặp
/// không mong muốn từ việc build lại widget.
class YoloImageInferenceService {
  YoloImageInferenceService({required Logger logger}) : _logger = logger;

  final Logger _logger;

  YOLO? _yolo;
  String? _activeModelPath;
  YOLOTask? _activeTask;
  bool? _activeUseGpu;

  Future<YoloImageInferenceResult> predict({
    required Uint8List imageBytes,
    required YoloModelDescriptor model,
    required YOLOTask task,
    required bool useGpu,
    required double confidenceThreshold,
    required double iouThreshold,
  }) async {
    await _ensureReady(model: model, task: task, useGpu: useGpu);

    final rawResult = await _yolo!.predict(
      imageBytes,
      confidenceThreshold: confidenceThreshold,
      iouThreshold: iouThreshold,
    );

    final detections = ((rawResult['detections'] as List?) ?? const <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map(YOLOResult.fromMap)
        .toList(growable: false);

    return YoloImageInferenceResult(
      originalImage: imageBytes,
      annotatedImage: rawResult['annotatedImage'] as Uint8List?,
      detections: detections,
    );
  }

  Future<void> _ensureReady({
    required YoloModelDescriptor model,
    required YOLOTask task,
    required bool useGpu,
  }) async {
    final shouldRecreate =
        _yolo == null ||
        _activeModelPath != model.path ||
        _activeTask != task ||
        _activeUseGpu != useGpu;

    if (!shouldRecreate) {
      return;
    }

    _disposeCurrent();

    _logger.i('Loading YOLO model ${model.path} for task ${task.name}');

    final next = YOLO(
      modelPath: model.path,
      task: task,
      useGpu: useGpu,
      useMultiInstance: true,
    );

    final loaded = await next.loadModel();
    if (!loaded) {
      next.dispose();
      throw StateError('Không thể tải model ${model.path}');
    }

    _yolo = next;
    _activeModelPath = model.path;
    _activeTask = task;
    _activeUseGpu = useGpu;
  }

  void dispose() {
    _disposeCurrent();
  }

  void _disposeCurrent() {
    _yolo?.dispose();
    _yolo = null;
    _activeModelPath = null;
    _activeTask = null;
    _activeUseGpu = null;
  }
}
