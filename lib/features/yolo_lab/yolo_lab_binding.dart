import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:yoloapp/core/services/yolo_image_inference_service.dart';
import 'package:yoloapp/core/services/yolo_model_file_service.dart';
import 'package:yoloapp/features/yolo_lab/yolo_lab_controller.dart';

/// Feature-owned binding that wires controller dependencies from the app locator.
class YoloLabBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<YoloLabController>(
      () => YoloLabController(
        imagePicker: Get.find<ImagePicker>(),
        logger: Get.find<Logger>(),
        imageInferenceService: Get.find<YoloImageInferenceService>(),
        modelFileService: Get.find<YoloModelFileService>(),
      ),
      fenix: true,
    );
  }
}
