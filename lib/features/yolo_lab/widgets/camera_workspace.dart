import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:yoloapp/features/yolo_lab/yolo_lab_controller.dart';
import 'package:yoloapp/shared/widgets/section_card.dart';

/// Bảng điều khiển camera trực tiếp được hỗ trợ bởi `YOLOView`.
class CameraWorkspace extends GetView<YoloLabController> {
  const CameraWorkspace({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Camera Live',
      subtitle:
          'Sử dụng `ultralytics_yolo` để chạy real-time inference và đổi model mà không rời camera screen.',
      child: Obx(() {
        final model = controller.selectedModel.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(
                  label: Text(
                    'Camera đang dùng: ${controller.activeModelSummary}',
                  ),
                ),
                Chip(
                  label: Text('Trạng thái: ${controller.modelLoadStateLabel}'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 9 / 14,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (controller.hasSelectedModel)
                      ColoredBox(
                        color: Colors.orangeAccent.withAlpha(20),
                        child: YOLOView(
                          key: ValueKey(
                            'camera-${controller.cameraViewRevision.value}-${model.path}-${controller.selectedTask.value.name}',
                          ),
                          controller: controller.cameraController,
                          modelPath: model.path,
                          task: controller.selectedTask.value,
                          useGpu: controller.useGpu.value,
                          confidenceThreshold:
                              controller.confidenceThreshold.value,
                          iouThreshold: controller.iouThreshold.value,
                          lensFacing: controller.isUsingFrontCamera.value
                              ? LensFacing.front
                              : LensFacing.back,
                          onResult: controller.handleLiveResults,
                          onPerformanceMetrics: (metrics) {
                            controller.handlePerformanceMetrics(metrics.fps);
                          },
                          onZoomChanged: controller.handleZoomChanged,
                        ),
                      )
                    else
                      const ColoredBox(
                        color: Colors.black,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Chưa có model. Hãy quay lại phần Model và chọn `Nạp từ tệp`.',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    if (controller.isSwitchingModel.value)
                      const ColoredBox(
                        color: Color(0x66000000),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (controller.isModelPreparing &&
                        !controller.isSwitchingModel.value)
                      const Align(
                        alignment: Alignment.topCenter,
                        child: LinearProgressIndicator(minHeight: 3),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonalIcon(
                  onPressed: controller.hasSelectedModel
                      ? controller.switchCameraLens
                      : null,
                  icon: const Icon(Icons.cameraswitch_outlined),
                  label: Text(
                    controller.isUsingFrontCamera.value
                        ? 'Camera trước'
                        : 'Camera sau',
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: controller.hasSelectedModel
                      ? () {
                          controller.cameraViewRevision.value++;
                        }
                      : null,
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Khởi động lại view'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Zoom ${(controller.currentZoom.value).toStringAsFixed(2)}x',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Slider(
              min: 1.0,
              max: 5.0,
              value: controller.currentZoom.value.clamp(1.0, 5.0),
              onChanged: (value) => controller.setZoomLevel(value),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(
                  label: Text(
                    'FPS ${controller.currentFps.value.toStringAsFixed(1)}',
                  ),
                ),
                Chip(
                  label: Text('Đối tượng ${controller.liveDetections.length}'),
                ),
                Chip(
                  label: Text('Model ${controller.selectedModel.value.label}'),
                ),
                if (controller.hasActiveModel)
                  Chip(
                    label: Text(
                      'Active ${controller.activeModel.value!.label}',
                    ),
                  ),
                Chip(label: Text('Task ${controller.selectedTask.value.name}')),
              ],
            ),
          ],
        );
      }),
    );
  }
}
