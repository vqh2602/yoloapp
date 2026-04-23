import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yoloapp/core/models/yolo_capture_mode.dart';
import 'package:yoloapp/core/utils/formatters.dart';
import 'package:yoloapp/features/yolo_lab/yolo_lab_controller.dart';
import 'package:yoloapp/shared/widgets/section_card.dart';

/// Các điều khiển để chuyển đổi nguồn model, task và các ngưỡng.
class ModelSourceCard extends GetView<YoloLabController> {
  const ModelSourceCard({super.key});

  Color _stateColor(BuildContext context) {
    switch (controller.modelLoadState.value) {
      case ModelLoadState.empty:
        return Colors.grey.shade200;
      case ModelLoadState.selected:
        return Colors.amber.shade100;
      case ModelLoadState.preparing:
        return Colors.orange.shade100;
      case ModelLoadState.ready:
        return Colors.green.shade100;
      case ModelLoadState.failed:
        return Colors.red.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Model Và Ngưỡng',
      subtitle:
          'Chỉ dùng 3 nguồn model: assets của app, URL `http/https`, hoặc tệp cục bộ. Với model custom không có metadata, hãy chọn đúng task.',
      child: Obx(() {
        final assetModels = controller.assetModelsForCurrentPlatform;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<ModelInputSource>(
              initialValue: controller.selectedInputSource.value,
              decoration: const InputDecoration(labelText: 'Nguồn model'),
              items: const [
                DropdownMenuItem(
                  value: ModelInputSource.asset,
                  child: Text('Assets của app'),
                ),
                DropdownMenuItem(
                  value: ModelInputSource.remoteUrl,
                  child: Text('URL'),
                ),
                DropdownMenuItem(
                  value: ModelInputSource.localFile,
                  child: Text('Tệp cục bộ'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.changeModelInputSource(value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              initialValue: controller.selectedTask.value,
              decoration: const InputDecoration(labelText: 'Task'),
              items: controller.availableTasks
                  .map(
                    (task) => DropdownMenuItem(
                      value: task,
                      child: Text(task.name),
                    ),
                  )
                  .toList(growable: false),
              onChanged: controller.changeTask,
            ),
            const SizedBox(height: 16),
            if (controller.selectedInputSource.value == ModelInputSource.asset)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue:
                        controller.selectedModel.value.isAsset &&
                            assetModels.contains(controller.selectedModel.value.path)
                        ? controller.selectedModel.value.path
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Model trong assets',
                    ),
                    items: assetModels
                        .map(
                          (path) => DropdownMenuItem(
                            value: path,
                            child: Text(path.split('/').last),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: assetModels.isEmpty
                        ? null
                        : controller.selectBundledAssetModel,
                  ),
                  if (assetModels.isEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Không tìm thấy model phù hợp trong `assets/models/` cho nền tảng hiện tại.',
                    ),
                  ],
                ],
              ),
            if (controller.selectedInputSource.value == ModelInputSource.localFile)
              FilledButton.tonalIcon(
                onPressed: controller.pickModelFile,
                icon: const Icon(Icons.file_open_outlined),
                label: const Text('Chọn tệp model'),
              ),
            if (controller.selectedInputSource.value == ModelInputSource.remoteUrl)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller.remoteModelUrlController,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    enableSuggestions: false,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Remote model URL',
                      hintText:
                          'Android: .../model.tflite | iOS: .../model.mlpackage.zip',
                    ),
                    onSubmitted: controller.applyRemoteModelUrl,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: controller.applyRemoteModelUrl,
                    icon: const Icon(Icons.link_outlined),
                    label: const Text('Dùng model từ URL'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _stateColor(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          'Trạng thái ${controller.modelLoadStateLabel}',
                        ),
                      ),
                      Chip(
                        label: Text(
                          'Task ${controller.selectedTask.value.name}',
                        ),
                      ),
                      Chip(
                        label: Text(
                          controller.captureMode.value == YoloCaptureMode.camera
                              ? 'Mode Camera'
                              : 'Mode Ảnh',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Đã chọn: ${controller.selectedModelSummary}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đang active: ${controller.activeModelSummary}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (controller.isModelPreparing) ...[
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 6),
                    Text(
                      controller.selectedModel.value.isRemoteUrl
                          ? 'Model URL đang được tải nền vào storage của app. Link lớn hoặc mạng chậm có thể mất khá lâu.'
                          : 'App đang chuẩn bị model trước khi suy luận.',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nguồn: ${controller.selectedModel.value.sourceLabel}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            Text(compactPath(controller.selectedModel.value.path)),
            const SizedBox(height: 8),
            const Text(
              'Assets: app tự bundle model. Local file: bạn chọn trực tiếp từ máy. URL: plugin sẽ tải model vào app storage trước khi load.',
            ),
            const SizedBox(height: 4),
            const Text(
              'Với CoreML trên iOS, đừng dán URL tới file con như `.../Data/com.apple.CoreML/model.mlmodel`; hãy dùng URL tới cả `.mlpackage.zip` hoặc `.zip` chứa trọn package.',
            ),
            const SizedBox(height: 4),
            const Text(
              'Không dùng URL `.pt` hoặc `.pth`: đó là trọng số PyTorch, không phải định dạng mobile mà plugin hỗ trợ.',
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ưu tiên GPU'),
              subtitle: const Text(
                'Tắt khi cần ổn định hơn trên thiết bị cũ hoặc model custom.',
              ),
              value: controller.useGpu.value,
              onChanged: controller.toggleGpu,
            ),
            const SizedBox(height: 4),
            Text(
              'Confidence ${controller.confidenceThreshold.value.toStringAsFixed(2)}',
            ),
            Slider(
              min: 0.05,
              max: 0.95,
              value: controller.confidenceThreshold.value,
              onChanged: controller.updateConfidenceThreshold,
            ),
            const SizedBox(height: 8),
            Text('IoU ${controller.iouThreshold.value.toStringAsFixed(2)}'),
            Slider(
              min: 0.10,
              max: 0.95,
              value: controller.iouThreshold.value,
              onChanged: controller.updateIoUThreshold,
            ),
            const SizedBox(height: 8),
            Text('Số lượng kết quả ${controller.numItemsThreshold.value}'),
            Slider(
              min: 1,
              max: 100,
              divisions: 99,
              value: controller.numItemsThreshold.value.toDouble(),
              onChanged: (value) {
                controller.updateNumItemsThreshold(value.round());
              },
            ),
          ],
        );
      }),
    );
  }
}
