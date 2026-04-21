import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:yoloapp/core/services/yolo_image_inference_service.dart';
import 'package:yoloapp/core/services/yolo_model_file_service.dart';

/// Registers cross-feature dependencies once at app startup.
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
