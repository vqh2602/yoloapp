import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:yoloapp/core/constants/app_constants.dart';
import 'package:yoloapp/core/models/yolo_model_descriptor.dart';

/// Opens the native file picker and validates custom model extensions.
class YoloModelFileService {
  Future<YoloModelDescriptor?> pickModelFile() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Chọn model YOLO',
      type: FileType.custom,
      allowedExtensions: AppConstants.supportedModelExtensions,
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final selectedPath = file.path;
    if (selectedPath == null || !File(selectedPath).existsSync()) {
      throw FileSystemException('Không tìm thấy tệp model đã chọn.', selectedPath);
    }

    final extension = path.extension(selectedPath).replaceFirst('.', '').toLowerCase();
    if (!AppConstants.supportedModelExtensions.contains(extension)) {
      throw UnsupportedError('Định dạng .$extension chưa được hỗ trợ.');
    }

    return YoloModelDescriptor.localFile(
      label: file.name,
      path: selectedPath,
    );
  }
}
