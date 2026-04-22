import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:yoloapp/core/services/yolo_image_inference_service.dart';
import 'package:yoloapp/core/services/yolo_model_file_service.dart';

/// Đăng ký các phụ thuộc chéo tính năng một lần khi khởi động ứng dụng.
Future<void> setupLocator() async {
  if (!Get.isRegistered<Logger>()) {
    Get.put<Logger>(Logger(), permanent: true);
  }

  if (!Get.isRegistered<ImagePicker>()) {
    Get.put<ImagePicker>(ImagePicker(), permanent: true);
  }

  if (!Get.isRegistered<YoloModelFileService>()) {
    Get.put<YoloModelFileService>(YoloModelFileService(), permanent: true);
  }

  if (!Get.isRegistered<YoloImageInferenceService>()) {
    Get.put<YoloImageInferenceService>(
      YoloImageInferenceService(logger: Get.find<Logger>()),
      permanent: true,
    );
  }
}
