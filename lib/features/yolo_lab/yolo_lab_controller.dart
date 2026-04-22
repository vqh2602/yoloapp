import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:yoloapp/app/config/configurations.dart';
import 'package:yoloapp/core/constants/app_constants.dart';
import 'package:yoloapp/core/models/yolo_capture_mode.dart';
import 'package:yoloapp/core/models/yolo_image_inference_result.dart';
import 'package:yoloapp/core/models/yolo_model_descriptor.dart';
import 'package:yoloapp/core/services/yolo_image_inference_service.dart';
import 'package:yoloapp/core/services/yolo_model_file_service.dart';

enum ModelLoadState { empty, selected, preparing, ready, failed }

/// Controller chính của tính năng.
///
/// Controller nắm giữ trạng thái hiển thị, ủy thác các công việc nặng cho các dịch vụ,
/// và giữ cho các widget màn hình chỉ tập trung vào việc render.
class YoloLabController extends GetxController {
  YoloLabController({
    required ImagePicker imagePicker,
    required Logger logger,
    required YoloImageInferenceService imageInferenceService,
    required YoloModelFileService modelFileService,
  }) : _imagePicker = imagePicker,
       _logger = logger,
       _imageInferenceService = imageInferenceService,
       _modelFileService = modelFileService;

  final ImagePicker _imagePicker;
  final Logger _logger;
  final YoloImageInferenceService _imageInferenceService;
  final YoloModelFileService _modelFileService;

  final YOLOViewController cameraController = YOLOViewController();
  final TextEditingController remoteModelUrlController =
      TextEditingController();
  Timer? _modelPreparationTimer;

  // Giữ ứng dụng ở chế độ hình ảnh theo mặc định để view camera chỉ được tạo
  // sau khi người dùng chuyển sang tab camera một cách rõ ràng.
  final Rx<YoloCaptureMode> captureMode = YoloCaptureMode.image.obs;
  final Rx<YOLOTask> selectedTask = YOLOTask.detect.obs;
  final Rx<YoloModelDescriptor> selectedModel = YoloModelDescriptor.empty().obs;

  final RxDouble confidenceThreshold =
      AppConstants.defaultConfidenceThreshold.obs;
  final RxDouble iouThreshold = AppConstants.defaultIoUThreshold.obs;
  final RxInt numItemsThreshold = AppConstants.defaultNumItemsThreshold.obs;
  final RxBool useGpu = Env.config.preferGpu.obs;

  final RxList<YOLOResult> liveDetections = <YOLOResult>[].obs;
  final RxList<YOLOResult> imageDetections = <YOLOResult>[].obs;
  final Rxn<Uint8List> selectedImageBytes = Rxn<Uint8List>();
  final Rxn<Uint8List> annotatedImageBytes = Rxn<Uint8List>();
  final RxnString selectedImageName = RxnString();
  final RxnString errorMessage = RxnString();
  final RxString statusMessage = ''.obs;
  final Rx<ModelLoadState> modelLoadState = ModelLoadState.empty.obs;
  final Rxn<YoloModelDescriptor> activeModel = Rxn<YoloModelDescriptor>();

  final RxDouble currentFps = 0.0.obs;
  final RxDouble currentZoom = 1.0.obs;
  final RxInt cameraViewRevision = 0.obs;
  final RxBool isSwitchingModel = false.obs;
  final RxBool isRunningImageInference = false.obs;
  final RxBool isUsingFrontCamera = false.obs;

  List<YOLOTask> get availableTasks => YOLOTask.values;

  List<String> get officialModelsForSelectedTask {
    final models = YOLO.officialModels(task: selectedTask.value);
    if (models.isNotEmpty) {
      return models;
    }

    final fallback = YOLO.defaultOfficialModel(task: selectedTask.value);
    return fallback == null ? const <String>[] : <String>[fallback];
  }

  String? get selectedOfficialModelId {
    if (!selectedModel.value.isOfficial || selectedModel.value.isEmpty) {
      return null;
    }

    return selectedModel.value.path;
  }

  String get activeImageLabel {
    return selectedImageName.value ?? 'Chưa có ảnh';
  }

  bool get hasSelectedModel => !selectedModel.value.isEmpty;
  bool get hasActiveModel => activeModel.value != null;
  bool get isModelPreparing => modelLoadState.value == ModelLoadState.preparing;

  String get selectedModelSummary {
    if (!hasSelectedModel) {
      return 'Chưa có model nào được chọn';
    }

    return '${selectedModel.value.sourceLabel}: ${selectedModel.value.label}';
  }

  String get activeModelSummary {
    final model = activeModel.value;
    if (model == null) {
      return 'Chưa có model nào active';
    }

    return '${model.sourceLabel}: ${model.label}';
  }

  String get modelLoadStateLabel {
    switch (modelLoadState.value) {
      case ModelLoadState.empty:
        return 'Chưa chọn';
      case ModelLoadState.selected:
        return 'Đã chọn';
      case ModelLoadState.preparing:
        return 'Đang tải / chuẩn bị';
      case ModelLoadState.ready:
        return 'Sẵn sàng';
      case ModelLoadState.failed:
        return 'Lỗi';
    }
  }

  @override
  void onInit() {
    super.onInit();
    statusMessage.value =
        'Hãy nạp model từ tệp trước. Official model của upstream hiện có thể trả 404.';
  }

  Future<void> changeCaptureMode(YoloCaptureMode mode) async {
    if (captureMode.value == mode) {
      return;
    }

    if (mode == YoloCaptureMode.camera && !hasSelectedModel) {
      errorMessage.value = 'Hãy chọn model trước khi mở camera.';
      statusMessage.value = 'Camera chỉ mở sau khi bạn nạp model hợp lệ.';
      return;
    }

    captureMode.value = mode;
    errorMessage.value = null;

    if (mode == YoloCaptureMode.camera) {
      statusMessage.value = 'Camera sẽ dùng ${selectedModel.value.label}.';
      cameraViewRevision.value++;
    } else {
      statusMessage.value = 'Chọn hoặc chụp ảnh để chạy YOLO một lần.';
    }
  }

  Future<void> changeTask(YOLOTask? task) async {
    if (task == null || task == selectedTask.value) {
      return;
    }

    selectedTask.value = task;
    errorMessage.value = null;

    if (selectedModel.value.isOfficial) {
      final nextOfficial = _defaultOfficialModel(task);
      selectedModel.value = YoloModelDescriptor.official(nextOfficial);
    }
    modelLoadState.value = hasSelectedModel
        ? ModelLoadState.selected
        : ModelLoadState.empty;

    liveDetections.clear();
    imageDetections.clear();
    annotatedImageBytes.value = null;
    statusMessage.value = 'Đã chuyển task sang ${task.name}.';

    await _reloadCameraIfNeeded();
  }

  Future<void> selectOfficialModel(String? modelId) async {
    if (modelId == null || modelId == selectedModel.value.path) {
      return;
    }

    selectedModel.value = YoloModelDescriptor.official(modelId);
    modelLoadState.value = ModelLoadState.selected;
    errorMessage.value = null;
    statusMessage.value = 'Đang dùng model chính thức $modelId.';

    await _reloadCameraIfNeeded();
  }

  Future<void> pickModelFile() async {
    try {
      final pickedModel = await _modelFileService.pickModelFile();
      if (pickedModel == null) {
        return;
      }

      selectedModel.value = pickedModel;
      activeModel.value = null;
      modelLoadState.value = ModelLoadState.selected;
      errorMessage.value = null;
      statusMessage.value =
          'Đã nạp model từ tệp. Hãy chắc task ${selectedTask.value.name} khớp với model nếu metadata không đầy đủ.';

      await _reloadCameraIfNeeded();
    } catch (error, stackTrace) {
      _logger.e(
        'Failed to pick YOLO model file',
        error: error,
        stackTrace: stackTrace,
      );
      errorMessage.value = error.toString();
    }
  }

  Future<void> applyRemoteModelUrl([String? rawUrl]) async {
    final input = (rawUrl ?? remoteModelUrlController.text).trim();
    final uri = Uri.tryParse(input);

    if (input.isEmpty) {
      errorMessage.value = 'Hãy nhập URL model trước khi nạp.';
      return;
    }

    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      errorMessage.value = 'URL model phải bắt đầu bằng http:// hoặc https://';
      return;
    }

    final supportedRemoteSuffixes = Platform.isIOS
        ? const <String>['.mlpackage.zip', '.mlmodel', '.mlpackage', '.zip']
        : const <String>['.tflite'];
    final lowerInput = input.toLowerCase();
    final isNestedCoreMlFile =
        lowerInput.contains('/data/com.apple.coreml/') ||
        lowerInput.endsWith('/model.mlmodel');
    final isSupportedRemoteModel = supportedRemoteSuffixes.any(
      lowerInput.endsWith,
    );

    if (Platform.isIOS && isNestedCoreMlFile) {
      errorMessage.value =
          'URL iOS đang trỏ vào file con bên trong CoreML package (`model.mlmodel`). Hãy dùng URL tới cả gói `.mlpackage.zip` hoặc `.zip` chứa đầy đủ weights.';
      modelLoadState.value = ModelLoadState.failed;
      _showError(errorMessage.value!);
      return;
    }

    if (!isSupportedRemoteModel) {
      errorMessage.value = Platform.isIOS
          ? 'URL model iOS phải trỏ trực tiếp tới `.mlpackage.zip`, `.mlpackage`, `.mlmodel` hoặc `.zip`. File `.pt` không chạy được với plugin này.'
          : 'URL model Android phải trỏ trực tiếp tới file `.tflite`. File `.pt` không chạy được với plugin này.';
      modelLoadState.value = ModelLoadState.failed;
      _showError(errorMessage.value!);
      return;
    }

    modelLoadState.value = ModelLoadState.preparing;
    statusMessage.value = 'Đang kiểm tra URL model...';
    errorMessage.value = null;

    final reachableError = await _validateRemoteModelUrl(uri);
    if (reachableError != null) {
      modelLoadState.value = ModelLoadState.failed;
      errorMessage.value = reachableError;
      _showError(reachableError);
      return;
    }

    final resolvedRemoteUrl = _rewriteRemoteUrlIfNeeded(uri);

    selectedModel.value = YoloModelDescriptor.remoteUrl(
      label: uri.pathSegments.isEmpty ? uri.host : uri.pathSegments.last,
      url: resolvedRemoteUrl,
    );
    activeModel.value = null;
    modelLoadState.value = ModelLoadState.selected;
    errorMessage.value = null;
    statusMessage.value = resolvedRemoteUrl == input
        ? 'Đã chọn model từ URL. Plugin sẽ tải model vào app storage trước khi load.'
        : 'Đã chọn model từ URL. App đã thêm marker để tránh plugin nhận nhầm đây là official model.';

    await _reloadCameraIfNeeded();
  }

  Future<void> pickImageFromGallery() async {
    await _loadImage(ImageSource.gallery);
  }

  Future<void> captureImageWithCamera() async {
    await _loadImage(ImageSource.camera);
  }

  Future<void> runImageInference() async {
    if (!hasSelectedModel) {
      errorMessage.value =
          'Hãy nạp model từ tệp hoặc chọn official model trước.';
      return;
    }

    final bytes = selectedImageBytes.value;
    if (bytes == null) {
      errorMessage.value = 'Hãy chọn ảnh trước khi chạy suy luận.';
      return;
    }

    isRunningImageInference.value = true;
    _startPreparationWatchdog(
      timeoutMessage:
          'Tải model quá lâu hoặc model URL không phản hồi. Hãy kiểm tra lại link model.',
    );
    errorMessage.value = null;

    try {
      final result = await _imageInferenceService.predict(
        imageBytes: bytes,
        model: selectedModel.value,
        task: selectedTask.value,
        useGpu: useGpu.value,
        confidenceThreshold: confidenceThreshold.value,
        iouThreshold: iouThreshold.value,
      );

      _applyImageResult(result);
      _markModelReady();
      statusMessage.value =
          'Ảnh đã được xử lý với ${imageDetections.length} kết quả.';
      _showInfo(
        'Suy luận hoàn tất',
        'Đã xử lý ảnh với ${imageDetections.length} kết quả.',
      );
    } catch (error, stackTrace) {
      _logger.e(
        'Single-image inference failed',
        error: error,
        stackTrace: stackTrace,
      );
      modelLoadState.value = ModelLoadState.failed;
      errorMessage.value = _presentError(error);
      _showError(errorMessage.value!);
    } finally {
      isRunningImageInference.value = false;
    }
  }

  Future<void> switchCameraLens() async {
    isUsingFrontCamera.value = !isUsingFrontCamera.value;
    currentZoom.value = 1.0;
    errorMessage.value = null;
    await cameraController.switchCamera();
  }

  Future<void> updateConfidenceThreshold(double value) async {
    confidenceThreshold.value = value;
    errorMessage.value = null;

    if (cameraController.isInitialized) {
      await cameraController.setConfidenceThreshold(value);
    }
  }

  Future<void> updateIoUThreshold(double value) async {
    iouThreshold.value = value;
    errorMessage.value = null;

    if (cameraController.isInitialized) {
      await cameraController.setIoUThreshold(value);
    }
  }

  Future<void> updateNumItemsThreshold(int value) async {
    numItemsThreshold.value = value;
    errorMessage.value = null;

    if (cameraController.isInitialized) {
      await cameraController.setNumItemsThreshold(value);
    }
  }

  Future<void> toggleGpu(bool enabled) async {
    useGpu.value = enabled;
    statusMessage.value = enabled
        ? 'GPU đã bật cho lần nạp model tiếp theo.'
        : 'GPU đã tắt để ưu tiên ổn định.';
    await _reloadCameraIfNeeded(forceRebuild: true);
  }

  Future<void> setZoomLevel(double value) async {
    currentZoom.value = value;
    await cameraController.setZoomLevel(value);
  }

  void handleLiveResults(List<YOLOResult> results) {
    _markModelReady();
    liveDetections.assignAll(results);
  }

  void handlePerformanceMetrics(double fps) {
    _markModelReady();
    currentFps.value = fps;
  }

  void handleZoomChanged(double zoomLevel) {
    currentZoom.value = zoomLevel;
  }

  @override
  void onClose() {
    _stopPreparationWatchdog();
    remoteModelUrlController.dispose();
    cameraController.stop();
    _imageInferenceService.dispose();
    super.onClose();
  }

  Future<void> _loadImage(ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(source: source);
      if (file == null) {
        return;
      }

      final bytes = await file.readAsBytes();
      selectedImageBytes.value = bytes;
      annotatedImageBytes.value = null;
      imageDetections.clear();
      selectedImageName.value = file.name;
      errorMessage.value = null;
      statusMessage.value = 'Ảnh đã sẵn sàng. Đang chạy YOLO...';

      if (captureMode.value != YoloCaptureMode.image) {
        captureMode.value = YoloCaptureMode.image;
      }

      await runImageInference();
    } catch (error, stackTrace) {
      _logger.e('Failed to load image', error: error, stackTrace: stackTrace);
      modelLoadState.value = ModelLoadState.failed;
      errorMessage.value = _presentError(error);
      _showError(errorMessage.value!);
    }
  }

  void _applyImageResult(YoloImageInferenceResult result) {
    selectedImageBytes.value = result.originalImage;
    annotatedImageBytes.value = result.annotatedImage;
    imageDetections.assignAll(result.detections);
  }

  String _defaultOfficialModel(YOLOTask task) {
    final defaultModel = YOLO.defaultOfficialModel(task: task);
    if (defaultModel != null) {
      return defaultModel;
    }

    final officialModels = YOLO.officialModels(task: task);
    if (officialModels.isNotEmpty) {
      return officialModels.first;
    }

    return Env.config.defaultOfficialModelId;
  }

  Future<void> _reloadCameraIfNeeded({bool forceRebuild = false}) async {
    liveDetections.clear();
    currentFps.value = 0.0;

    if (captureMode.value != YoloCaptureMode.camera) {
      return;
    }

    if (!hasSelectedModel) {
      errorMessage.value = 'Hãy nạp model trước khi khởi động camera.';
      return;
    }

    if (forceRebuild || !cameraController.isInitialized) {
      _startPreparationWatchdog(
        timeoutMessage:
            'Chuẩn bị model quá lâu. Có thể URL model không phản hồi hoặc plugin không tải xong model.',
      );
      activeModel.value = null;
      cameraViewRevision.value++;
      return;
    }

    isSwitchingModel.value = true;
    _startPreparationWatchdog(
      timeoutMessage:
          'Đổi model quá lâu. Có thể URL model không phản hồi hoặc model không hợp lệ.',
    );
    activeModel.value = null;

    try {
      await cameraController.switchModel(
        selectedModel.value.path,
        selectedTask.value,
      );
      await cameraController.setThresholds(
        confidenceThreshold: confidenceThreshold.value,
        iouThreshold: iouThreshold.value,
        numItemsThreshold: numItemsThreshold.value,
      );
    } catch (error, stackTrace) {
      _logger.e(
        'Live model switch failed',
        error: error,
        stackTrace: stackTrace,
      );
      modelLoadState.value = ModelLoadState.failed;
      errorMessage.value = _presentError(error);
      _showError(errorMessage.value!);
      cameraViewRevision.value++;
    } finally {
      isSwitchingModel.value = false;
    }
  }

  String _presentError(Object error) {
    final raw = error.toString();

    if (raw.contains('HTTP 404') ||
        raw.contains(
          'Failed to download model from https://github.com/ultralytics/yolo-flutter-app/releases',
        )) {
      return 'Official model download đang lỗi upstream: GitHub release `v0.3.0` không có file model tương ứng nên trả 404. Hãy dùng `Nạp từ tệp` với model local.';
    }

    if (raw.contains('MODEL_INSPECTION_FAILED') ||
        raw.contains('Failed to parse the model specification')) {
      if (raw.contains('weight.bin') ||
          raw.contains('Could not open /var/mobile') ||
          raw.contains('Unable to parse ML Program')) {
        return 'CoreML URL chưa đúng gói đầy đủ. Bạn đang trỏ vào `model.mlmodel` nhưng model này còn phụ thuộc file weights như `weight.bin`. Hãy dùng URL tới `.mlpackage.zip` hoặc `.zip` của cả package.';
      }

      return Platform.isIOS
          ? 'Model URL không đúng định dạng iOS. `ultralytics_yolo` không load được file `.pt`; hãy dùng model export `.mlpackage.zip` hoặc `.mlmodel`.'
          : 'Model URL không đúng định dạng Android. `ultralytics_yolo` không load được file `.pt`; hãy dùng model export `.tflite`.';
    }

    if (raw.contains('Failed to download model from http')) {
      return 'Không tải được model từ URL đã nhập. Hãy kiểm tra link trực tiếp tới file model và quyền truy cập mạng.';
    }

    if (raw.contains('Failed to extract') && raw.contains('.mlpackage.zip')) {
      return 'Không giải nén được CoreML package. File URL phải là một `.mlpackage.zip` hợp lệ và sau khi giải nén phải có `Manifest.json` ở root của package. Hãy zip cả thư mục `*.mlpackage`, không zip riêng file bên trong.';
    }

    return raw;
  }

  void _markModelReady() {
    if (!hasSelectedModel) {
      return;
    }

    _stopPreparationWatchdog();
    final wasReady = modelLoadState.value == ModelLoadState.ready;
    activeModel.value = selectedModel.value;
    modelLoadState.value = ModelLoadState.ready;
    if (!wasReady && captureMode.value == YoloCaptureMode.camera) {
      _showInfo(
        'Model sẵn sàng',
        'Camera đang dùng ${selectedModel.value.label}.',
      );
    }
  }

  void _showInfo(String title, String message) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade50,
      borderColor: Colors.green.shade200,
      borderWidth: 1,
      colorText: Colors.black87,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
    );
  }

  void _showError(String message) {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Có lỗi xảy ra',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade50,
      borderColor: Colors.red.shade200,
      borderWidth: 1,
      colorText: Colors.black87,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
    );
  }

  void _startPreparationWatchdog({required String timeoutMessage}) {
    _stopPreparationWatchdog();
    modelLoadState.value = ModelLoadState.preparing;
    _modelPreparationTimer = Timer(const Duration(seconds: 20), () {
      if (modelLoadState.value != ModelLoadState.preparing) {
        return;
      }

      activeModel.value = null;
      modelLoadState.value = ModelLoadState.failed;
      errorMessage.value = timeoutMessage;
      statusMessage.value = 'Load model thất bại hoặc bị treo.';
      _showError(timeoutMessage);
    });
  }

  void _stopPreparationWatchdog() {
    _modelPreparationTimer?.cancel();
    _modelPreparationTimer = null;
  }

  Future<String?> _validateRemoteModelUrl(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 8));
      request.followRedirects = true;
      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      await response.drain<void>();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return 'URL model trả về HTTP ${response.statusCode}. Hãy kiểm tra lại link tải trực tiếp.';
      }

      return null;
    } on TimeoutException {
      return 'URL model không phản hồi trong thời gian cho phép. Có thể link chết hoặc server quá chậm.';
    } on SocketException {
      return 'Không kết nối được tới URL model. Hãy kiểm tra mạng hoặc domain.';
    } catch (_) {
      return 'Không kiểm tra được URL model. Hãy xác nhận đây là link tải trực tiếp tới file model.';
    } finally {
      client.close(force: true);
    }
  }

  String _rewriteRemoteUrlIfNeeded(Uri uri) {
    final fileName = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
    final normalizedFileName = fileName
        .replaceAll('.mlpackage.zip', '')
        .replaceAll('.mlpackage', '')
        .replaceAll('.mlmodelc', '')
        .replaceAll('.mlmodel', '')
        .replaceAll('.tflite', '');
    final officialIds = YOLO.officialModels();

    if (!officialIds.contains(normalizedFileName)) {
      return uri.toString();
    }

    final queryParameters = <String, String>{
      ...uri.queryParameters,
      'codex_remote': '1',
    };

    return uri.replace(queryParameters: queryParameters).toString();
  }
}
